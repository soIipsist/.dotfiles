import winreg


def get_subkey_names(key):
    """ Retrieves the names of subkeys under a given key in the Windows Registry """
    
    keys = []
    key_length = winreg.QueryInfoKey(key)[0]
    for i in range(0, key_length):
        value = winreg.EnumKey(key, i)
        keys.append(value)
    return keys



def get_key_value_pair(keys):
    """ Retrieves key and value dictionary of the given keys """
    
    key_values = {}
    
    for key in keys:
        values = []
        value_length = winreg.QueryInfoKey(key)[1]
        for i in range(0, value_length):
            try:
                value = winreg.EnumValue(key, i)
                values.append(value)
                key_values[key] = values
            except Exception as e:
                print(e)
    
    return key_values


       
def get_opened_subkeys(key, subkeys, access=winreg.KEY_READ):
    """ Retrieves opened subkeys given a key """
    
    keys = []
    for s in subkeys:
        try:
            t = winreg.OpenKey(key, s, 0, access)
            keys.append(t)
        except Exception as e:
            print(e)
    return keys

# hkey = winreg.HKEY_CURRENT_USER
# subkey_names = get_subkey_names(hkey)
# subkeys = get_opened_subkeys(hkey, subkey_names)
# key_values = get_key_value_pair(subkeys)