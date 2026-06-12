import sys

def check_braces(filename):
    with open(filename, 'r') as f:
        content = f.read()

    stack = []
    lines = content.split('\n')
    
    for i, line in enumerate(lines):
        # Ignore comments for simplistic parsing
        line = line.split('//')[0]
        for j, char in enumerate(line):
            if char == '{':
                stack.append((i+1, j+1))
            elif char == '}':
                if not stack:
                    print(f"Error: Unmatched closing brace at line {i+1}, col {j+1}")
                    return
                stack.pop()
    if stack:
        print(f"Error: Unmatched opening brace at line {stack[-1][0]}, col {stack[-1][1]}")
    else:
        print("Braces matched successfully.")

check_braces('arma3mercenaries/kill/arma3mercenaries_killHandler.sqf')
