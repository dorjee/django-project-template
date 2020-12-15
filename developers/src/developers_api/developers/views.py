from rest_framework import status, viewsets
from rest_framework.response import Response

class DevelopersView(viewsets.ViewSet):
    def list(self, request):
        """Just returns a string, for now."""
        return Response("developers API service!")
