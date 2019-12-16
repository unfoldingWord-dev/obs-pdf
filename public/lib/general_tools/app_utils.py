import os


def get_app_root():
    current_dir = os.path.dirname(os.path.abspath(__file__))
    return os.path.dirname(os.path.dirname(os.path.dirname(current_dir)))


def get_resources_dir():
    return os.path.join(get_app_root(), 'resources/')


def get_output_dir():
    return os.path.join(get_app_root(), 'output/')
