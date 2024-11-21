from django.shortcuts import get_object_or_404
from rest_framework import viewsets
from .serializers import InventorySerializer
from .models import Inventory

class InventoryView(viewsets.ModelViewSet):
    serializer_class = InventorySerializer
    queryset = Inventory.objects.all()
    lookup_field = 'Nom_du_produit'

    # Override the retrieve method to decode the product name
    def get_object(self):
        product_name = self.kwargs.get('Nom_du_produit').replace('-', '/')  # Replace hyphens back with slashes
        return get_object_or_404(Inventory, Nom_du_produit=product_name)
