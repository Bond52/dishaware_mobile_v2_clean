import { Lightbulb, Flame, Clock, MapPin } from 'lucide-react';
import { Card } from './ui/card';
import { Button } from './ui/button';

interface HomeScreenProps {
  onDishClick: (dishId: number) => void;
  onRestaurantClick?: () => void;
  onHostModeClick?: () => void;
}

export function HomeScreen({ onDishClick, onRestaurantClick, onHostModeClick }: HomeScreenProps) {
  const dishes = [
    {
      id: 1,
      name: "Bowl Buddha Avocat & Quinoa",
      restaurant: "Green Kitchen",
      calories: 420,
      image: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=300&fit=crop",
      prepTime: "25 min",
      matchScore: 95
    },
    {
      id: 2,
      name: "Saumon Grillé, Légumes de Saison",
      restaurant: "Fresh & Co",
      calories: 380,
      image: "https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=400&h=300&fit=crop",
      prepTime: "30 min",
      matchScore: 92
    },
    {
      id: 3,
      name: "Curry de Lentilles Corail",
      restaurant: "Spice Garden",
      calories: 340,
      image: "https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=400&h=300&fit=crop",
      prepTime: "20 min",
      matchScore: 88
    }
  ];

  return (
    <div className="pb-24 px-4 pt-6">
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-2xl mb-1">Bonjour, Marie</h1>
        <p className="text-sm text-gray-500">Découvrez vos recommandations du jour</p>
      </div>

      {/* Insight Card */}
      <Card className="mb-6 p-4 bg-gradient-to-br from-emerald-50 to-teal-50 border-emerald-200">
        <div className="flex gap-3">
          <div className="flex-shrink-0 mt-0.5">
            <div className="w-10 h-10 rounded-full bg-emerald-100 flex items-center justify-center">
              <Lightbulb className="w-5 h-5 text-emerald-600" />
            </div>
          </div>
          <div className="flex-1">
            <h3 className="font-medium text-emerald-900 mb-1">Insight détecté</h3>
            <p className="text-sm text-emerald-800 leading-relaxed">
              Nous avons remarqué que vous appréciez souvent les plats combinant <span className="font-medium">carotte + citron</span>.
            </p>
            <p className="text-xs text-emerald-700 mt-2">
              Nos recommandations s'ajustent à vos préférences 🌱
            </p>
          </div>
        </div>
      </Card>

      {/* Daily Goals */}
      <div className="mb-6 p-4 bg-gray-50 rounded-lg">
        <div className="flex items-center justify-between mb-2">
          <span className="text-sm font-medium text-gray-700">Objectif calorique journalier</span>
          <span className="text-sm font-bold text-gray-900">1480 / 2000 kcal</span>
        </div>
        <div className="w-full bg-gray-200 rounded-full h-2">
          <div className="bg-emerald-500 h-2 rounded-full" style={{ width: '74%' }}></div>
        </div>
        <p className="text-xs text-gray-500 mt-2">Encore 520 kcal disponibles pour ce soir</p>
      </div>

      {/* Quick Actions */}
      <div className="mb-6 grid grid-cols-2 gap-3">
        <Button 
          variant="outline" 
          className="h-auto py-4 flex flex-col items-center gap-2"
          onClick={onRestaurantClick}
        >
          <MapPin className="w-5 h-5 text-emerald-600" />
          <span className="text-sm font-medium">Restaurants près de moi</span>
        </Button>
        <Button 
          variant="outline" 
          className="h-auto py-4 flex flex-col items-center gap-2"
          onClick={onHostModeClick}
        >
          <Lightbulb className="w-5 h-5 text-purple-600" />
          <span className="text-sm font-medium">Mode Hôte</span>
        </Button>
      </div>

      {/* Recommended Dishes */}
      <div className="mb-4">
        <h2 className="text-lg font-semibold mb-3">Recommandations pour vous</h2>
      </div>

      <div className="space-y-4">
        {dishes.map((dish) => (
          <Card 
            key={dish.id} 
            className="overflow-hidden cursor-pointer hover:shadow-md transition-shadow"
            onClick={() => onDishClick(dish.id)}
          >
            <div className="relative">
              <img 
                src={dish.image} 
                alt={dish.name}
                className="w-full h-48 object-cover"
              />
              <div className="absolute top-3 right-3 bg-white/95 backdrop-blur-sm px-3 py-1.5 rounded-full flex items-center gap-1.5 shadow-sm">
                <Flame className="w-4 h-4 text-orange-500" />
                <span className="text-sm font-semibold">{dish.calories} kcal</span>
              </div>
              <div className="absolute bottom-3 left-3 bg-emerald-500 text-white px-3 py-1 rounded-full text-xs font-medium">
                {dish.matchScore}% compatible
              </div>
            </div>
            <div className="p-4">
              <h3 className="font-semibold text-gray-900 mb-1">{dish.name}</h3>
              <p className="text-sm text-gray-500 mb-3">{dish.restaurant}</p>
              <div className="flex items-center text-xs text-gray-400">
                <Clock className="w-3.5 h-3.5 mr-1" />
                <span>{dish.prepTime}</span>
              </div>
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}