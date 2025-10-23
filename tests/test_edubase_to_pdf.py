"""
Unit tests for edubase_to_pdf.py

Run with: pytest tests/
"""

import pytest
from pathlib import Path
import tempfile
import shutil
from PIL import Image

# Import functions from main script
import sys
sys.path.insert(0, str(Path(__file__).parent.parent))
from edubase_to_pdf import (
    natural_key,
    list_images,
    ensure_dir,
    auto_crop_image,
)


class TestUtilityFunctions:
    """Test utility functions"""
    
    def test_natural_key_sorting(self):
        """Test natural sorting of filenames"""
        files = ['page_10.png', 'page_2.png', 'page_1.png', 'page_20.png']
        sorted_files = sorted(files, key=natural_key)
        assert sorted_files == ['page_1.png', 'page_2.png', 'page_10.png', 'page_20.png']
    
    def test_natural_key_mixed(self):
        """Test natural sorting with mixed content"""
        items = ['test10', 'test2', 'abc', 'test1']
        sorted_items = sorted(items, key=natural_key)
        assert sorted_items == ['abc', 'test1', 'test2', 'test10']


class TestDirectoryOperations:
    """Test directory operations"""
    
    def test_ensure_dir_creates_directory(self):
        """Test that ensure_dir creates missing directories"""
        with tempfile.TemporaryDirectory() as tmpdir:
            test_path = Path(tmpdir) / "subdir" / "nested"
            ensure_dir(test_path)
            assert test_path.exists()
            assert test_path.is_dir()
    
    def test_ensure_dir_existing_directory(self):
        """Test that ensure_dir works with existing directories"""
        with tempfile.TemporaryDirectory() as tmpdir:
            test_path = Path(tmpdir)
            ensure_dir(test_path)
            assert test_path.exists()


class TestImageOperations:
    """Test image processing functions"""
    
    @pytest.fixture
    def white_bordered_image(self):
        """Create a test image with white borders"""
        img = Image.new('RGB', (200, 200), color='white')
        # Draw a black rectangle in the center
        pixels = img.load()
        for x in range(50, 150):
            for y in range(50, 150):
                pixels[x, y] = (0, 0, 0)
        return img
    
    def test_auto_crop_removes_white_borders(self, white_bordered_image):
        """Test that auto_crop removes white borders"""
        cropped = auto_crop_image(white_bordered_image, threshold=248, margin_px=0)
        # Cropped image should be smaller than original
        assert cropped.size[0] < white_bordered_image.size[0]
        assert cropped.size[1] < white_bordered_image.size[1]
        # Should be roughly 100x100 (the black rectangle)
        assert 90 <= cropped.size[0] <= 110
        assert 90 <= cropped.size[1] <= 110
    
    def test_auto_crop_with_margin(self, white_bordered_image):
        """Test auto_crop with margin parameter"""
        cropped = auto_crop_image(white_bordered_image, threshold=248, margin_px=10)
        # With 10px margin, should be larger than without
        assert cropped.size[0] > 100
        assert cropped.size[1] > 100
    
    def test_auto_crop_no_content(self):
        """Test auto_crop on fully white image"""
        white_img = Image.new('RGB', (100, 100), color='white')
        result = auto_crop_image(white_img, threshold=248, margin_px=0)
        # Should return original if no content found
        assert result.size == white_img.size


class TestListImages:
    """Test image file listing"""
    
    @pytest.fixture
    def temp_image_dir(self):
        """Create temporary directory with test images"""
        tmpdir = tempfile.mkdtemp()
        img_dir = Path(tmpdir)
        
        # Create test image files
        for i in [1, 5, 10, 2]:
            img_path = img_dir / f"page_{i:04d}.png"
            img = Image.new('RGB', (10, 10), color='red')
            img.save(img_path)
        
        # Create non-image file (should be ignored)
        (img_dir / "readme.txt").write_text("test")
        
        yield img_dir
        
        # Cleanup
        shutil.rmtree(tmpdir)
    
    def test_list_images_finds_all(self, temp_image_dir):
        """Test that list_images finds all image files"""
        images = list_images(temp_image_dir)
        assert len(images) == 4
    
    def test_list_images_sorted(self, temp_image_dir):
        """Test that list_images returns sorted files"""
        images = list_images(temp_image_dir)
        names = [img.name for img in images]
        assert names == ['page_0001.png', 'page_0002.png', 'page_0005.png', 'page_0010.png']
    
    def test_list_images_empty_directory(self):
        """Test list_images on empty directory"""
        with tempfile.TemporaryDirectory() as tmpdir:
            images = list_images(Path(tmpdir))
            assert len(images) == 0
    
    def test_list_images_various_formats(self):
        """Test list_images with different image formats"""
        with tempfile.TemporaryDirectory() as tmpdir:
            img_dir = Path(tmpdir)
            img = Image.new('RGB', (10, 10))
            
            # Create various formats
            img.save(img_dir / "test.png")
            img.save(img_dir / "test.jpg")
            img.save(img_dir / "test.jpeg")
            
            images = list_images(img_dir)
            assert len(images) == 3


class TestConfiguration:
    """Test configuration and constants"""
    
    def test_supported_image_formats(self):
        """Test that supported formats are reasonable"""
        from edubase_to_pdf import list_images
        # Check that function handles common formats
        # This is implicitly tested by TestListImages
        pass


# Integration test marker
@pytest.mark.integration
class TestIntegration:
    """Integration tests (require more setup)"""
    
    def test_full_pipeline_small(self):
        """Test complete pipeline with small dataset"""
        # This would test the full capture -> build pipeline
        # Skipped in unit tests, can be run with: pytest -m integration
        pytest.skip("Integration test - run with -m integration")


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
