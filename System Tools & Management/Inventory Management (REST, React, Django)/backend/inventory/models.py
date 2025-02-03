from django.db import models
# Create your models here.

class Inventory(models.Model):
    Nom_du_produit = models.CharField(max_length=120, unique=True)
    Description_du_produit = models.TextField()
    Quantité_actuelle_en_stock = models.IntegerField()
    Seuil_minimum_en_stock = models.IntegerField()

    def _str_(self):
        return self.Nom_du_produit

