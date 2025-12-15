from django import template

register = template.Library()


@register.filter
def get_item(obj, key):
    """
    Safely get value by key from dictionaries in templates.
    """
    try:
        if isinstance(obj, dict):
            return obj.get(key, "")
        return ""
    except Exception:
        return ""


