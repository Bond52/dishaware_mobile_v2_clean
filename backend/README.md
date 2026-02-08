# Backend DishAware

API Express + MongoDB (Mongoose) pour gérer le profil utilisateur.

## Démarrage

1. Configurer l’environnement :

```
MONGO_URI=mongodb://localhost:27017/dishaware
MOCK_USER_ID=64b7f9c2f5c1f2b3a4c5d6e7
```

2. Lancer le serveur :

```
npm install
npm run dev
```

## Auth mock (provisoire)

Le `userId` est récupéré depuis :
- `Authorization: Bearer <userId>`
- ou `x-user-id`
- ou `MOCK_USER_ID` en variable d’environnement

## Endpoints

- `POST /api/profile` → créer ou remplacer le profil
- `GET /api/profile/me` → récupérer le profil
- `PUT /api/profile` → mise à jour partielle
- `DELETE /api/profile` → suppression du profil

## Exemples de payload

### Création / remplacement (POST)

```json
{
  "firstName": "Bertrand",
  "lastName": "Dupont",
  "dailyCalories": 2000,
  "allergies": ["gluten", "soja"],
  "diets": ["keto"],
  "favoriteCuisines": ["française", "japonaise"],
  "favoriteIngredients": ["avocat", "saumon"],
  "activityLevel": "moderate",
  "orderFrequency": "3-4 fois / semaine",
  "hasCompletedOnboarding": true
}
```

### Mise à jour partielle (PUT)

```json
{
  "dailyCalories": 1800,
  "favoriteIngredients": ["avocat", "quinoa", "tomate"]
}
```
