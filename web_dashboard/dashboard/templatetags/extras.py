from django import template

register = template.Library()


@register.filter
def get_item(obj, key):
    try:
        if isinstance(obj, dict):
            return obj.get(key, "")
        return ""
    except Exception:
        return ""


