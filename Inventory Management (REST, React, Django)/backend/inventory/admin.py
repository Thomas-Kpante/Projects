from django.contrib import admin
from .models import Inventory

# Register your models here.

class TodoAdmin(admin.ModelAdmin):
    list_display = ('Nom_du_produit','Description_du_produit','Quantité_actuelle_en_stock','Seuil_minimum_en_stock')


admin.site.register(Inventory, TodoAdmin)