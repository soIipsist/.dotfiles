import os
import subprocess
import validators

def is_valid_dir(string, raiseError=True):
    if os.path.isdir(string):
        return string
    if raiseError:
        raise NotADirectoryError(string)  

def is_valid_path(string, raiseError=True):
    if os.path.exists(string):
        return string
    
    if raiseError:
        raise FileNotFoundError(string)


def is_git_repository(git_repository:str):
    try:
        subprocess.run(["git", "rev-parse", "--is-inside-work-tree"], cwd=git_repository, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
        return git_repository
    except subprocess.CalledProcessError:
        raise ValueError(f"'{git_repository}' is not a git repository.")
    
def is_valid_url(url:str):
    if validators.url(url):
        return url
    
    raise ValueError(f"The url '{url}' is not valid.")