from django.shortcuts import render
from .firebase_config import db
from django.shortcuts import redirect
import json
from google.cloud import firestore as gcf
from django.views.decorators.http import require_POST
from django.http import HttpResponseBadRequest
from django.contrib.auth.decorators import login_required


# Helper: return list of Firestore documents with embedded id
def _docs_to_list(collection_name: str):
    docs = db.collection(collection_name).stream()
    items = []
    for doc in docs:
        data = doc.to_dict() or {}
        data["id"] = doc.id
        items.append(data)
    return items


# Dashboard home: show high-level counts
@login_required(login_url='login')
def home(request):
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


# Drivers list: search and sort
@login_required(login_url='login')
def drivers_list(request):
    sort_value = (request.GET.get("sort") or "newest").lower()
    search_value = (request.GET.get("search") or "").strip().lower()
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


# Rides list: include driver/passenger names and dynamic columns
@login_required(login_url='login')
def rides_list(request):
    sort_value = (request.GET.get("sort") or "newest").lower()
    search_value = (request.GET.get("search") or "").strip().lower()
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
    for r in rides:
        for k, v in list(r.items()):
            if k == "id":
                continue
            if isinstance(v, (dict, list)):
                try:
                    r[k] = json.dumps(v, ensure_ascii=False)
                except Exception:
                    r[k] = str(v)
    columns_set = set()
    for r in rides:
        columns_set.update([k for k in r.keys() if k != "id"])
    columns = sorted(columns_set)
    context = {"rides": rides, "columns": columns}
    return render(request, "pages/rides.html", context)


# Complaints list: searchable cards
@login_required(login_url='login')
def complaints_list(request):
    sort_value = (request.GET.get("sort") or "newest").lower()
    search_value = (request.GET.get("search") or "").strip().lower()
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


# Support tickets list: search and 
@login_required(login_url='login')
def support_list(request):
    sort_value = (request.GET.get("sort") or "newest").lower()
    search_value = (request.GET.get("search") or "").strip().lower()
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


# Users list: search and sort
@login_required(login_url='login')
def users_list(request):
    sort_value = (request.GET.get("sort") or "newest").lower()
    search_value = (request.GET.get("search") or "").strip().lower()
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



# Update complaint status then redirect
@login_required(login_url='login')
@require_POST
def update_complaint_status(request, complaint_id: str):
    new_status = request.POST.get("status")
    if not new_status:
        return HttpResponseBadRequest("Missing status")
    try:
        db.collection("complaints").document(complaint_id).update({"status": new_status})
    except Exception as exc:
        print("Failed to update complaint:", complaint_id, exc)
    return redirect("complaints_list")

# Update support ticket status then redirect
@login_required(login_url='login')
@require_POST
def update_support_status(request, ticket_id: str):
    new_status = request.POST.get("status")
    if not new_status:
        return HttpResponseBadRequest("Missing status")
    try:
        db.collection("support_tickets").document(ticket_id).update({"status": new_status})
    except Exception as exc:
        print("Failed to update support ticket:", ticket_id, exc)
    return redirect("support_list")


# Update user fields then redirect
@login_required(login_url='login')
@require_POST
def update_user(request, user_id: str):
    payload = {
        "name": request.POST.get("name"),
        "phone": request.POST.get("phone"),
    }
    update_data = {k: v for k, v in payload.items() if v is not None}
    if not update_data:
        return redirect("users_list")
    try:
        db.collection("users").document(user_id).update(update_data)
    except Exception as exc:
        print("Failed to update user:", user_id, exc)
    return redirect("users_list")


# Update driver fields then redirect
@login_required(login_url='login')
@require_POST
def update_driver(request, driver_id: str):
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

