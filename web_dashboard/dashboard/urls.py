from django.urls import path
from . import views

urlpatterns = [
    path("", views.home, name="home"),
    path("drivers/", views.drivers_list, name="drivers"),
    path("drivers/update/<str:driver_id>/", views.update_driver, name="update_driver"),
    path("users/", views.users_list, name="users"),
    path("users/", views.users_list, name="users_list"),
    path("users/update/<str:user_id>/", views.update_user, name="update_user"),
    path("rides/", views.rides_list, name="rides"),
    path("complaints/", views.complaints_list, name="complaints"),
    path("complaints/", views.complaints_list, name="complaints_list"),
    path("complaints/<str:complaint_id>/status/", views.update_complaint_status, name="update_complaint_status"),
    path("complaints/update/<str:complaint_id>/", views.update_complaint_status, name="update_complaint_status"),
    path("support/", views.support_list, name="support"),
    path("support/", views.support_list, name="support_list"),
    path("support/<str:ticket_id>/status/", views.update_support_status, name="update_support_status"),
    path("support/update/<str:ticket_id>/", views.update_support_status, name="update_support_status"),
]


