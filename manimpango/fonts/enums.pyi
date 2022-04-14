from enum import Enum

class Style(Enum):
    NORMAL = ...
    ITALIC = ...
    OBLIQUE = ...

class Weight(Enum):
    NORMAL = ...
    BOLD = ...
    THIN = ...
    ULTRALIGHT = ...
    LIGHT = ...
    BOOK = ...
    MEDIUM = ...
    SEMIBOLD = ...
    ULTRABOLD = ...
    HEAVY = ...
    ULTRAHEAVY = ...

class Variant(Enum):
    """
    An enumeration specifying capitalization variant of the font.
    Attributes
    ----------
    NORMAL :
        A normal font.
    SMALL_CAPS :
        A font with the lower case characters replaced by smaller variants
        of the capital characters.
    """
    NORMAL = ...
    SMALL_CAPS = ...
