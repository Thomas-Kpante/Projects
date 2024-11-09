from rest_framework import serializers
from .models import Inventory

class InventorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Inventory
        fields = ('Nom_du_produit','Description_du_produit','Quantité_actuelle_en_stock','Seuil_minimum_en_stock')