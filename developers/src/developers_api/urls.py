"""developers URL Configuration"""

from rest_framework import routers
from django.urls import path, include

from developers_api.developers.views import DevelopersView

router = routers.DefaultRouter()
router.register(r'developers', DevelopersView, basename='developers')

urlpatterns = [
    path('', include((router.urls, 'developers'), namespace='developers')),
]
