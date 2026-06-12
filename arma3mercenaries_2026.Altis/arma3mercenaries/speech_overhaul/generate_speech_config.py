import os

base_dir = "/home/brian-vasquez/aim-a3m/arma3mercenaries_2026.Altis/arma3mercenaries/speech_overhaul/sounds/west"
relative_base_path = "arma3mercenaries\\speech_overhaul\\sounds\\west"

cfg_sounds = []
sqf_arrays = {}

for root, dirs, files in os.walk(base_dir):
    for file in files:
        if file.endswith(".ogg"):
            # Get category from folder name
            category = os.path.basename(root)
            
            # Create classname
            filename_no_ext = os.path.splitext(file)[0]
            classname = f"A3M_speech_west_{category}_{filename_no_ext}"
            
            # Create relative path for CfgSounds
            rel_path = f"{relative_base_path}\\{category}\\{file}"
            
            # CfgSounds entry
            cfg_sounds.append(f"class {classname} {{\n    name = \"{classname}\";\n    sound[] = {{\"{rel_path}\", 2, 1, 50}};\n    titles[] = {{}};\n}};")
            
            # Add to arrays
            if category not in sqf_arrays:
                sqf_arrays[category] = []
            sqf_arrays[category].append(f'"{classname}"')

# Write cfgSpeechSounds.hpp
with open("/home/brian-vasquez/aim-a3m/arma3mercenaries_2026.Altis/arma3mercenaries/speech_overhaul/cfgSpeechSounds.hpp", "w") as f:
    f.write("// A3M Speech Overhaul - Auto-Generated CfgSounds\n")
    f.write("\n".join(cfg_sounds))

# Write fn_initSpeechArrays.sqf
with open("/home/brian-vasquez/aim-a3m/arma3mercenaries_2026.Altis/arma3mercenaries/speech_overhaul/fn_initSpeechArrays.sqf", "w") as f:
    f.write("// A3M Speech Overhaul - Global Sound Arrays\n")
    for category, classnames in sqf_arrays.items():
        array_name = f"A3M_Speech_West_{category.capitalize()}"
        f.write(f"{array_name} = [\n    {', '.join(classnames)}\n];\npublicVariable \"{array_name}\";\n\n")

print("Generated cfgSpeechSounds.hpp and fn_initSpeechArrays.sqf!")
