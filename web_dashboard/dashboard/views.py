from django.shortcuts import render
from .firebase_config import db
from django.shortcuts import redirect
import json
from google.cloud import firestore as gcf


def _docs_to_list(collection_name: str):
    """
    Fetch all Firestore documents from a collection and return a list of dicts including ids.
    """
    docs = db.collection(collection_name).stream()
    items = []
    for doc in docs:
        data = doc.to_dict() or {}
        data["id"] = doc.id
        items.append(data)
    return items


def home(request):
    """
    Dashboard home: show counts for drivers, users, rides, complaints.
    """
    drivers_count = len(_docs_to_list("drivers"))
    users_count = len(_docs_to_list("users"))
    rides_count = len(_docs_to_list("rides"))
    complaints_count = len(_docs_to_list("complaints"))
    support_count = len(_docs_to_list("support_tickets"))
    context = {
        "drivers_count": drivers_count,
        "users_count": users_count,
        "rides_count": rides_count,
        "complaints_count": complaints_count,
        "support_count": support_count,
    }
    return render(request, "pages/home.html", context)


def drivers_list(request):
    """
    List all drivers.
    """
    sort_value = (request.GET.get("sort") or "newest").lower()
    search_value = (request.GET.get("search") or "").strip().lower()
    # Order by createdAt with fallback
    try:
        direction = gcf.Query.ASCENDING if sort_value == "oldest" else gcf.Query.DESCENDING
        q = db.collection("drivers").order_by("createdAt", direction=direction)
        if not search_value:
            q = q.limit(50)
        docs = q.stream()
        drivers = []
        for d in docs:
            data = d.to_dict() or {}
            data["id"] = d.id
            drivers.append(data)
    except Exception:
        drivers = _docs_to_list("drivers")
    # Python-side filtering (case-insensitive)
    if search_value:
        def _match(d):
            fields = [
                d.get("fullName", ""),
                d.get("phone", ""),
                d.get("vehiclePlate", ""),
                d.get("vehicleBrand", ""),
            ]
            return any(search_value in str(v).lower() for v in fields if v is not None)
        drivers = [d for d in drivers if _match(d)]
    if drivers:
        print("DEBUG DRIVER:", drivers[0])
    context = {"drivers": drivers, "search_query": search_value, "sort_value": sort_value}
    return render(request, "pages/drivers.html", context)


def rides_list(request):
    """
    List all rides, with dynamic columns based on union of keys.
    """
    sort_value = (request.GET.get("sort") or "newest").lower()
    search_value = (request.GET.get("search") or "").strip().lower()
    # Order by createdAt with fallback
    try:
        direction = gcf.Query.ASCENDING if sort_value == "oldest" else gcf.Query.DESCENDING
        q = db.collection("rides").order_by("createdAt", direction=direction)
        if not search_value:
            q = q.limit(50)
        docs = q.stream()
        rides = []
        for d in docs:
            data = d.to_dict() or {}
            data["id"] = d.id
            rides.append(data)
    except Exception:
        rides = _docs_to_list("rides")
    # Build lookup maps for drivers and users to show human names
    driver_ids = set()
    user_ids = set()
    for r in rides:
        did = r.get("driverId")
        if did:
            driver_ids.add(did)
        pid = r.get("passengerId") or r.get("userId") or r.get("riderId")
        if pid:
            user_ids.add(pid)

    driver_id_to_name = {}
    for did in driver_ids:
        try:
            snap = db.collection("drivers").document(did).get()
            if snap.exists:
                data = snap.to_dict() or {}
                driver_id_to_name[did] = data.get("fullName") or "Not Assigned"
            else:
                driver_id_to_name[did] = "Not Assigned"
        except Exception:
            driver_id_to_name[did] = "Not Assigned"

    user_id_to_name = {}
    for uid in user_ids:
        try:
            snap = db.collection("users").document(uid).get()
            if snap.exists:
                data = snap.to_dict() or {}
                user_id_to_name[uid] = data.get("name") or "Not Assigned"
            else:
                user_id_to_name[uid] = "Not Assigned"
        except Exception:
            user_id_to_name[uid] = "Not Assigned"

    for r in rides:
        did = r.get("driverId")
        pid = r.get("passengerId") or r.get("userId") or r.get("riderId")
        r["driverName"] = driver_id_to_name.get(did, "Not Assigned")
        r["passengerName"] = user_id_to_name.get(pid, "Not Assigned")
    # Python-side filtering
    if search_value:
        def _match_r(v):
            fields = [
                v.get("driverName", ""),
                v.get("passengerName", ""),
                v.get("id", ""),
                v.get("pickupAddress", ""),
                v.get("destinationAddress", ""),
            ]
            return any(search_value in str(x).lower() for x in fields if x is not None)
        rides = [r for r in rides if _match_r(r)]
    # Pre-format complex values so templates can render directly without type checks
    for r in rides:
        for k, v in list(r.items()):
            if k == "id":
                continue
            if isinstance(v, (dict, list)):
                try:
                    r[k] = json.dumps(v, ensure_ascii=False)
                except Exception:
                    r[k] = str(v)
    # Determine a stable set of columns (union of keys, excluding 'id')
    columns_set = set()
    for r in rides:
        columns_set.update([k for k in r.keys() if k != "id"])
    columns = sorted(columns_set)
    context = {"rides": rides, "columns": columns}
    return render(request, "pages/rides.html", context)


def complaints_list(request):
    """
    List all complaints as cards.
    """
    sort_value = (request.GET.get("sort") or "newest").lower()
    search_value = (request.GET.get("search") or "").strip().lower()
    # Order by createdAt with fallback
    try:
        direction = gcf.Query.ASCENDING if sort_value == "oldest" else gcf.Query.DESCENDING
        q = db.collection("complaints").order_by("createdAt", direction=direction)
        if not search_value:
            q = q.limit(50)
        docs = q.stream()
        complaints = []
        for d in docs:
            data = d.to_dict() or {}
            data["id"] = d.id
            complaints.append(data)
    except Exception:
        complaints = _docs_to_list("complaints")
    if search_value:
        def _match_c(c):
            fields = [
                c.get("rideId", ""),
                c.get("complaintText", ""),
            ]
            return any(search_value in str(x).lower() for x in fields if x is not None)
        complaints = [c for c in complaints if _match_c(c)]
    context = {"complaints": complaints, "search_query": search_value, "sort_value": sort_value}
    return render(request, "pages/complaints.html", context)


def support_list(request):
    """
    List all support tickets from 'support_tickets' collection.
    """
    sort_value = (request.GET.get("sort") or "newest").lower()
    search_value = (request.GET.get("search") or "").strip().lower()
    # Order by createdAt with fallback
    try:
        direction = gcf.Query.ASCENDING if sort_value == "oldest" else gcf.Query.DESCENDING
        q = db.collection("support_tickets").order_by("timestamp", direction=direction)
        if not search_value:
            q = q.limit(50)
        docs = q.stream()
        tickets = []
        for d in docs:
            data = d.to_dict() or {}
            data["id"] = d.id
            tickets.append(data)
    except Exception:
        tickets = _docs_to_list("support_tickets")
    if tickets:
        print("DEBUG SUPPORT:", tickets[0])
    if search_value:
        def _match_s(t):
            fields = [
                t.get("name", ""),
                t.get("phone", ""),
                t.get("universityId", ""),
                t.get("message", ""),
            ]
            return any(search_value in str(x).lower() for x in fields if x is not None)
        tickets = [t for t in tickets if _match_s(t)]
    context = {"tickets": tickets, "search_query": search_value, "sort_value": sort_value}
    return render(request, "pages/support.html", context)


def users_list(request):
    """
    List all users.
    """
    sort_value = (request.GET.get("sort") or "newest").lower()
    search_value = (request.GET.get("search") or "").strip().lower()
    # Order by createdAt with fallback
    try:
        direction = gcf.Query.ASCENDING if sort_value == "oldest" else gcf.Query.DESCENDING
        q = db.collection("users").order_by("createdAt", direction=direction)
        if not search_value:
            q = q.limit(50)
        docs = q.stream()
        users = []
        for d in docs:
            data = d.to_dict() or {}
            data["id"] = d.id
            users.append(data)
    except Exception:
        users = _docs_to_list("users")
    if search_value:
        def _match_u(u):
            fields = [
                u.get("name", ""),
                u.get("phone", ""),
                u.get("universityId", ""),
                u.get("uid", ""),
            ]
            return any(search_value in str(x).lower() for x in fields if x is not None)
        users = [u for u in users if _match_u(u)]
    context = {"users": users, "search_query": search_value, "sort_value": sort_value}
    return render(request, "pages/users.html", context)


from django.views.decorators.http import require_POST
from django.http import HttpResponseBadRequest


@require_POST
def update_complaint_status(request, complaint_id: str):
    """
    Update the complaint 'status' field and redirect back to complaints list.
    """
    new_status = request.POST.get("status")
    if not new_status:
        return HttpResponseBadRequest("Missing status")
    try:
        db.collection("complaints").document(complaint_id).update({"status": new_status})
    except Exception as exc:
        print("Failed to update complaint:", complaint_id, exc)
    return redirect("complaints_list")

@require_POST
def update_support_status(request, ticket_id: str):
    """
    Update a support ticket 'status' and redirect back to support list.
    """
    new_status = request.POST.get("status")
    if not new_status:
        return HttpResponseBadRequest("Missing status")
    try:
        db.collection("support_tickets").document(ticket_id).update({"status": new_status})
    except Exception as exc:
        print("Failed to update support ticket:", ticket_id, exc)
    return redirect("support_list")


@require_POST
def update_user(request, user_id: str):
    """
    Update user document fields (name, phone, role) then redirect to users list.
    """
    payload = {
        "name": request.POST.get("name"),
        "phone": request.POST.get("phone"),
    }
    # Remove None entries to avoid overwriting with null
    update_data = {k: v for k, v in payload.items() if v is not None}
    if not update_data:
        return redirect("users_list")
    try:
        db.collection("users").document(user_id).update(update_data)
    except Exception as exc:
        print("Failed to update user:", user_id, exc)
    return redirect("users_list")


@require_POST
def update_driver(request, driver_id: str):
    """
    Update driver document fields and redirect back to drivers list.
    Editable: fullName, phone, vehicleBrand, vehicleModel, vehicleYear, vehiclePlate, vehicleColor, seats
    """
    payload = {
        "fullName": request.POST.get("fullName"),
        "phone": request.POST.get("phone"),
        "vehicleBrand": request.POST.get("vehicleBrand"),
        "vehicleModel": request.POST.get("vehicleModel"),
        "vehicleYear": request.POST.get("vehicleYear"),
        "vehiclePlate": request.POST.get("vehiclePlate"),
        "vehicleColor": request.POST.get("vehicleColor"),
        "seats": request.POST.get("seats"),
    }
    update_data = {k: v for k, v in payload.items() if v is not None}
    if not update_data:
        return redirect("drivers")
    try:
        db.collection("drivers").document(driver_id).update(update_data)
    except Exception as exc:
        print("Failed to update driver:", driver_id, exc)
    return redirect("drivers")

