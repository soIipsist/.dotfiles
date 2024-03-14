import unittest
import os
parentdir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.sys.path.insert(0,parentdir) 
from scripts.utils.file_handling import read_json_file
from scripts.ytdlp.ytdlp import download, get_options, settings


 
class TestYtdlp(unittest.TestCase):
    def setUp(self) -> None:
        
        self.format = "audio"
        self.settings = settings
        self.options = None
        
        self.url_playlist = "https://www.youtube.com/playlist?list=PLT1F2nOxLHOdvoVsC2xZlk3AX2nbJqdLW"
        self.url_audio = ""
        self.url_video = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
        # self.url_video = "https://www.arte.tv/fr/videos/107115-001-A/la-fille-de-kiev-1-6/"
        self.url_video_with_subs = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
        
        self.urls = []
        
        self.audio_urls = []
        self.video_urls = []
        
    
    def test_get_options(self):
        
        self.assertIsNotNone(self.settings)
        
        if self.format == "video":
            self.assertEqual(self.settings.get(self.format), "video_options.json")
        
        elif self.format == "audio":
             self.assertEqual(self.settings.get(self.format), "audio_options.json")
        
        self.options = get_options(self.format)
        self.assertIsNotNone(self.options)
        

    def test_download_video(self):
        self.format = "video"
        self.options = get_options(self.format)
        
        # video url
        self.urls = [self.url_video]
        download(self.urls, self.options, True)
        
        # video urls
        # self.urls = [self.url_audio, self.url_video]
        # download(self.urls, self.options, True) # download multiple video urls
        
        
        # playlist url
        # download(self.urls, self.options, True)
        
      
        
    
    
    # def test_download_audio(self):
    #     self.format = "audio"
    #     self.options = get_options(self.format)
    #     self.urls = [""]
    #     download(self.urls, self.options, True)
    
    
  
    

if __name__ == "__main__":
    unittest.main()