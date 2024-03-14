import yt_dlp
import argparse
import json
import os
parentdir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.sys.path.insert(0,parentdir) 
from utils.file_handling import read_json_file
from utils.path_operations import is_valid_dir,is_valid_path, is_valid_url
from pprint import PrettyPrinter

settings = read_json_file(f"{parentdir}/ytdlp/settings.json")
pp = PrettyPrinter(indent=2)
    
def get_options(format:str, options_file:str = None):
    if options_file:
        options = read_json_file(options_file)
    else:
        options = read_json_file(f"{parentdir}/ytdlp/{settings.get(format)}")
    
    return options
    
    
        
def download(urls:list, options:dict, extract_info:bool):
    for url in urls:
        with yt_dlp.YoutubeDL(options) as ytdl:
            if extract_info:
                info  = ytdl.extract_info(url, download=False)
                print(info)

            status_code = ytdl.download(url)
            print("Status code: " ,status_code)
                
if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('urls', nargs='+', type=is_valid_url)
    parser.add_argument('-f','--format', default='video', choices=['video', 'audio'])
    parser.add_argument('-o','--output_directory', type=is_valid_dir, default=None)
    parser.add_argument('--options', default=None, type=is_valid_path)
    parser.add_argument('--extract_info', default=False)
    args = vars(parser.parse_args())
    
    urls = args.get('urls')
    format = args.get('format')
    options = args.get('options')
    extract_info = args.get('extract_info')
    output_directory = args.get('output_directory')
    options = get_options(format, options)
    
    if(output_directory):
        options['outtmpl'] = f"{output_directory}/%(title)s.%(ext)s"
    
    pp.pprint(options)
    download(urls, options, extract_info)