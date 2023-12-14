# This file contains helper utilities for grade, add_grade, and print_grade

import sys, os



def round_if_integral(x):
    """Rounds x if it's within 0.001 of an integer"""
    return int(x) if abs(x - round(x)) < 0.001 else x



def color_print(color, message):
    """Prints a message to stderr in the specified color"""

    # Dictionary mapping color names to escape sequences
    colors = {
        "red": "\033[91m",
        "cyan": "\033[96m",
        "green": "\033[92m",
        "yellow": "\033[93m",
        "blue": "\033[94m",
        "magenta": "\033[95m",
        "white": "\033[97m",
        "reset": "\033[0m"
    }

    # Print the message
    color_code = colors.get(color, colors["reset"])
    print(f"{color_code}{message}{colors['reset']}", file=sys.stderr)



def verbose_message(message):
    """Prints a message in blue if GRADE_VERBOSE is set"""
    if os.getenv("GRADE_VERBOSE"):
        color_print("blue", f"INFO: {message}")



def error_message(message):
    """Prints a message in red"""
    color_print("red", f"ERROR: {message}")



def print_result(grade_type, points, description):
    """Prints a grade result if GRADE_QUIET isn't set"""
    if not os.getenv("GRADE_QUIET"):
        # No need to print a float if it's meant to be an integer
        points = round_if_integral(points)

        # Print, with slight differences in formatting based on grade_type
        if grade_type == "failure": color_print("red",    f"FAILURE:             {description} (0/{points})")
        if grade_type == "extra":   color_print("cyan",   f"EXTRA CREDIT:        {description} (+{points})")
        if grade_type == "success": color_print("green",  f"SUCCESS:             {description} ({points}/{points})")
        if grade_type == "missed":  color_print("yellow", f"MISSED EXTRA CREDIT: {description} (0/+{points})")
