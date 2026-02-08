import { useState } from 'react';
import { ArrowLeft, Flame, Clock, ThumbsUp, ThumbsDown, Star, Info } from 'lucide-react';
import { Card } from './ui/card';
import { Button } from './ui/button';

interface DishDetailScreenProps {
  dishId: number;
  onBack: () => void;
  onFeedback: (type: 'like' | 'dislike', level: 'dish' | 'preparation') => void;
}

export function DishDetailScreen({ dishId, onBack, onFeedback }: DishDetailScreenProps) {
  const [dishLiked, setDishLiked] = useState<boolean | null>(null);
  const [prepLiked, setPrepLiked] = useState<boolean | null>(null);

  // Mock data - in real app would fetch based on dishId
  const dish = {
    id: dishId,
    name: "Bowl Buddha Avocat & Quinoa",
    restaurant: "Green Kitchen",
    calories: 420,
    image: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&h=400&fit=crop",
    prepTime: "25 min",
    rating: 4.8,
    description: "Un bowl complet et équilibré avec quinoa bio, avocat frais, pois chiches rôtis, carottes râpées et sauce citron-tahini.",
    ingredients: [
      "Quinoa bio (80g)",
      "Avocat (1/2)",
      "Pois chiches rôtis (60g)",
      "Carotte râpée (50g)",
      "Épinards frais (30g)",
      "Sauce citron-tahini (25ml)",
      "Graines de sésame"
    ],
    macros: {
      proteins: 18,
      carbs: 45,
      fats: 22
    },
    previousPreparations: [
      { restaurant: "Green Kitchen", liked: true, date: "2 jours" },
      { restaurant: "Bio & Co", liked: true, date: "1 semaine" },
      { restaurant: "Veggie House", liked: false, date: "2 semaines" }
    ]
  };

  const handleDishFeedback = (liked: boolean) => {
    setDishLiked(liked);
    onFeedback(liked ? 'like' : 'dislike', 'dish');
  };

  const handlePrepFeedback = (liked: boolean) => {
    setPrepLiked(liked);
    onFeedback(liked ? 'like' : 'dislike', 'preparation');
  };

  return (
    <div className="pb-24">
      {/* Header with back button */}
      <div className="sticky top-0 z-10 bg-white border-b px-4 py-3 flex items-center gap-3">
        <button 
          onClick={onBack}
          className="w-9 h-9 rounded-full bg-gray-100 flex items-center justify-center hover:bg-gray-200"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h1 className="font-semibold text-lg">Détails du plat</h1>
      </div>

      {/* Dish Image */}
      <div className="relative">
        <img 
          src={dish.image} 
          alt={dish.name}
          className="w-full h-64 object-cover"
        />
        <div className="absolute top-4 right-4 bg-white/95 backdrop-blur-sm px-3 py-2 rounded-full flex items-center gap-2 shadow-lg">
          <Flame className="w-5 h-5 text-orange-500" />
          <span className="font-semibold">{dish.calories} kcal</span>
        </div>
      </div>

      <div className="px-4 pt-4">
        {/* Dish Header */}
        <div className="mb-4">
          <h2 className="text-2xl font-bold mb-2">{dish.name}</h2>
          <div className="flex items-center justify-between">
            <p className="text-gray-600">{dish.restaurant}</p>
            <div className="flex items-center gap-1">
              <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
              <span className="font-medium">{dish.rating}</span>
            </div>
          </div>
          <div className="flex items-center gap-2 text-sm text-gray-500 mt-2">
            <Clock className="w-4 h-4" />
            <span>{dish.prepTime}</span>
          </div>
        </div>

        {/* Description */}
        <Card className="mb-4 p-4">
          <p className="text-sm text-gray-700 leading-relaxed">{dish.description}</p>
        </Card>

        {/* Macros */}
        <Card className="mb-4 p-4">
          <h3 className="font-semibold mb-3">Valeurs nutritionnelles</h3>
          <div className="grid grid-cols-3 gap-4">
            <div className="text-center">
              <div className="text-2xl font-bold text-emerald-600">{dish.macros.proteins}g</div>
              <div className="text-xs text-gray-500 mt-1">Protéines</div>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold text-blue-600">{dish.macros.carbs}g</div>
              <div className="text-xs text-gray-500 mt-1">Glucides</div>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold text-orange-600">{dish.macros.fats}g</div>
              <div className="text-xs text-gray-500 mt-1">Lipides</div>
            </div>
          </div>
        </Card>

        {/* Ingredients */}
        <Card className="mb-4 p-4">
          <h3 className="font-semibold mb-3">Ingrédients</h3>
          <ul className="space-y-2">
            {dish.ingredients.map((ingredient, idx) => (
              <li key={idx} className="text-sm text-gray-700 flex items-start">
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 mt-1.5 mr-2 flex-shrink-0"></span>
                {ingredient}
              </li>
            ))}
          </ul>
        </Card>

        {/* Dish vs Preparation Feedback */}
        <Card className="mb-4 p-4 bg-gradient-to-br from-blue-50 to-indigo-50 border-blue-200">
          <div className="flex gap-2 mb-3">
            <Info className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" />
            <div>
              <h3 className="font-semibold text-blue-900 mb-1">Votre avis compte</h3>
              <p className="text-sm text-blue-800">
                Aidez-nous à améliorer vos recommandations en distinguant le plat de sa préparation.
              </p>
            </div>
          </div>
        </Card>

        {/* Dish Feedback */}
        <Card className="mb-4 p-4">
          <h3 className="font-semibold mb-3">Aimez-vous ce type de plat ?</h3>
          <p className="text-sm text-gray-600 mb-4">Le concept "Bowl Buddha Avocat & Quinoa" en général</p>
          <div className="flex gap-3">
            <Button
              variant={dishLiked === true ? "default" : "outline"}
              className={`flex-1 ${dishLiked === true ? 'bg-emerald-600 hover:bg-emerald-700' : ''}`}
              onClick={() => handleDishFeedback(true)}
            >
              <ThumbsUp className="w-4 h-4 mr-2" />
              J'aime
            </Button>
            <Button
              variant={dishLiked === false ? "default" : "outline"}
              className={`flex-1 ${dishLiked === false ? 'bg-gray-600 hover:bg-gray-700' : ''}`}
              onClick={() => handleDishFeedback(false)}
            >
              <ThumbsDown className="w-4 h-4 mr-2" />
              Je n'aime pas
            </Button>
          </div>
        </Card>

        {/* Preparation Feedback */}
        <Card className="mb-4 p-4">
          <h3 className="font-semibold mb-3">Cette préparation vous plaît ?</h3>
          <p className="text-sm text-gray-600 mb-4">La version de <span className="font-medium">{dish.restaurant}</span></p>
          <div className="flex gap-3">
            <Button
              variant={prepLiked === true ? "default" : "outline"}
              className={`flex-1 ${prepLiked === true ? 'bg-emerald-600 hover:bg-emerald-700' : ''}`}
              onClick={() => handlePrepFeedback(true)}
            >
              <ThumbsUp className="w-4 h-4 mr-2" />
              J'aime
            </Button>
            <Button
              variant={prepLiked === false ? "default" : "outline"}
              className={`flex-1 ${prepLiked === false ? 'bg-gray-600 hover:bg-gray-700' : ''}`}
              onClick={() => handlePrepFeedback(false)}
            >
              <ThumbsDown className="w-4 h-4 mr-2" />
              Je n'aime pas
            </Button>
          </div>
        </Card>

        {/* Previous Preparations */}
        <Card className="mb-4 p-4">
          <h3 className="font-semibold mb-3">Préparations testées</h3>
          <div className="space-y-3">
            {dish.previousPreparations.map((prep, idx) => (
              <div key={idx} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <div className="flex-1">
                  <p className="font-medium text-sm">{prep.restaurant}</p>
                  <p className="text-xs text-gray-500">Il y a {prep.date}</p>
                </div>
                <div className={`flex items-center gap-1 ${prep.liked ? 'text-emerald-600' : 'text-gray-400'}`}>
                  {prep.liked ? (
                    <ThumbsUp className="w-4 h-4 fill-current" />
                  ) : (
                    <ThumbsDown className="w-4 h-4 fill-current" />
                  )}
                </div>
              </div>
            ))}
          </div>
        </Card>

        {/* Order Button */}
        <div className="mb-6">
          <Button className="w-full bg-emerald-600 hover:bg-emerald-700 py-6 text-base">
            Commander ce plat
          </Button>
        </div>
      </div>
    </div>
  );
}
