import { useState } from 'react';
import { ArrowLeft, MapPin, Star, Sparkles, AlertCircle, CheckCircle2, Users } from 'lucide-react';
import { Card } from './ui/card';
import { Button } from './ui/button';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from './ui/dialog';

interface RestaurantScreenProps {
  onBack: () => void;
  onDishClick: (dishId: number) => void;
}

export function RestaurantScreen({ onBack, onDishClick }: RestaurantScreenProps) {
  const [showPresenceDialog, setShowPresenceDialog] = useState(false);
  const [presenceSignaled, setPresenceSignaled] = useState(false);

  // Mock restaurant data
  const restaurant = {
    name: "Green Kitchen",
    rating: 4.8,
    address: "24 Rue de la Paix, 75002 Paris",
    isPartner: true
  };

  const categories = [
    {
      id: 'sure-like',
      title: "Vous allez sûrement aimer",
      subtitle: "Basé sur vos préférences et votre historique",
      icon: CheckCircle2,
      color: 'emerald',
      dishes: [
        {
          id: 101,
          name: "Salade César Revisitée",
          calories: 380,
          matchScore: 96,
          image: "https://images.unsplash.com/photo-1546793665-c74683f339c1?w=400&h=300&fit=crop"
        },
        {
          id: 102,
          name: "Bowl Méditerranéen",
          calories: 410,
          matchScore: 94,
          image: "https://images.unsplash.com/photo-1623428187969-5da2dcea5ebf?w=400&h=300&fit=crop"
        }
      ]
    },
    {
      id: 'discover',
      title: "À découvrir absolument",
      subtitle: "Nouveaux profils de saveurs qui pourraient vous plaire",
      icon: Sparkles,
      color: 'purple',
      dishes: [
        {
          id: 103,
          name: "Tataki de Thon, Sésame & Gingembre",
          calories: 320,
          matchScore: 78,
          image: "https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400&h=300&fit=crop"
        }
      ]
    },
    {
      id: 'adjustments',
      title: "Avec quelques ajustements",
      subtitle: "Plats adaptables à vos préférences",
      icon: AlertCircle,
      color: 'blue',
      dishes: [
        {
          id: 104,
          name: "Risotto aux Champignons",
          calories: 480,
          matchScore: 72,
          adjustments: ["Sans parmesan (allergie)", "Portion réduite"],
          image: "https://images.unsplash.com/photo-1476124369491-c59cf6a4e1d5?w=400&h=300&fit=crop"
        }
      ]
    },
    {
      id: 'not-recommend',
      title: "Probablement pas pour vous",
      subtitle: "Contient des ingrédients que vous évitez habituellement",
      icon: AlertCircle,
      color: 'gray',
      dishes: [
        {
          id: 105,
          name: "Tarte aux Noix de Pécan",
          calories: 520,
          matchScore: 12,
          reasons: ["Contient fruits à coque (allergie)", "Trop calorique"],
          image: "https://images.unsplash.com/photo-1535920527002-b35e96722eb9?w=400&h=300&fit=crop"
        }
      ]
    }
  ];

  const handleSignalPresence = () => {
    setPresenceSignaled(true);
    setShowPresenceDialog(false);
  };

  return (
    <div className="pb-24">
      {/* Header */}
      <div className="sticky top-0 z-10 bg-white border-b px-4 py-3">
        <div className="flex items-center gap-3 mb-3">
          <button 
            onClick={onBack}
            className="w-9 h-9 rounded-full bg-gray-100 flex items-center justify-center hover:bg-gray-200"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div className="flex-1">
            <h1 className="font-semibold text-lg">{restaurant.name}</h1>
            <div className="flex items-center gap-2 text-sm text-gray-600">
              <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
              <span>{restaurant.rating}</span>
            </div>
          </div>
        </div>
      </div>

      <div className="px-4 pt-4">
        {/* Partner Banner */}
        {restaurant.isPartner && (
          <Card className="mb-4 p-4 bg-gradient-to-r from-emerald-500 to-teal-500 text-white border-0">
            <div className="flex items-start gap-3">
              <div className="w-10 h-10 rounded-full bg-white/20 flex items-center justify-center flex-shrink-0">
                <MapPin className="w-5 h-5" />
              </div>
              <div className="flex-1">
                <h3 className="font-semibold mb-1">Restaurant partenaire DishAware</h3>
                <p className="text-sm text-white/90 mb-3">
                  Menu adapté à vos préférences disponible. Vous pouvez signaler votre présence pour une expérience optimale.
                </p>
                {!presenceSignaled ? (
                  <Button 
                    variant="outline"
                    className="bg-white/10 border-white/30 text-white hover:bg-white/20"
                    onClick={() => setShowPresenceDialog(true)}
                  >
                    <Users className="w-4 h-4 mr-2" />
                    Signaler ma présence
                  </Button>
                ) : (
                  <div className="flex items-center gap-2 text-sm bg-white/20 px-3 py-2 rounded-lg">
                    <CheckCircle2 className="w-4 h-4" />
                    <span>Présence signalée • Profil partagé</span>
                  </div>
                )}
              </div>
            </div>
          </Card>
        )}

        {/* Restaurant Address */}
        <div className="mb-6 flex items-start gap-2 text-sm text-gray-600">
          <MapPin className="w-4 h-4 mt-0.5 flex-shrink-0" />
          <span>{restaurant.address}</span>
        </div>

        {/* AI Recommendation Categories */}
        {categories.map((category) => {
          const Icon = category.icon;
          const colorClasses = {
            emerald: 'from-emerald-50 to-emerald-100 border-emerald-200 text-emerald-700',
            purple: 'from-purple-50 to-purple-100 border-purple-200 text-purple-700',
            blue: 'from-blue-50 to-blue-100 border-blue-200 text-blue-700',
            gray: 'from-gray-50 to-gray-100 border-gray-200 text-gray-700'
          }[category.color];

          const iconColorClasses = {
            emerald: 'bg-emerald-100 text-emerald-600',
            purple: 'bg-purple-100 text-purple-600',
            blue: 'bg-blue-100 text-blue-600',
            gray: 'bg-gray-100 text-gray-600'
          }[category.color];

          return (
            <div key={category.id} className="mb-6">
              {/* Category Header */}
              <Card className={`mb-3 p-4 bg-gradient-to-br border ${colorClasses}`}>
                <div className="flex items-start gap-3">
                  <div className={`w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 ${iconColorClasses}`}>
                    <Icon className="w-5 h-5" />
                  </div>
                  <div>
                    <h3 className="font-semibold mb-1">{category.title}</h3>
                    <p className="text-sm opacity-90">{category.subtitle}</p>
                  </div>
                </div>
              </Card>

              {/* Dishes in Category */}
              <div className="space-y-3">
                {category.dishes.map((dish) => (
                  <Card 
                    key={dish.id}
                    className="overflow-hidden cursor-pointer hover:shadow-md transition-shadow"
                    onClick={() => onDishClick(dish.id)}
                  >
                    <div className="flex gap-3">
                      <img 
                        src={dish.image}
                        alt={dish.name}
                        className="w-24 h-24 object-cover flex-shrink-0"
                      />
                      <div className="flex-1 p-3 pr-4">
                        <h4 className="font-semibold text-sm mb-1">{dish.name}</h4>
                        <div className="flex items-center gap-3 text-xs text-gray-500 mb-2">
                          <span>{dish.calories} kcal</span>
                          <span className={`font-medium ${
                            dish.matchScore >= 80 ? 'text-emerald-600' :
                            dish.matchScore >= 60 ? 'text-blue-600' :
                            'text-gray-600'
                          }`}>
                            {dish.matchScore}% compatible
                          </span>
                        </div>
                        
                        {/* Adjustments or Reasons */}
                        {dish.adjustments && (
                          <div className="space-y-1">
                            {dish.adjustments.map((adj, idx) => (
                              <div key={idx} className="text-xs text-blue-600 flex items-start gap-1">
                                <span className="text-blue-400 mt-0.5">•</span>
                                <span>{adj}</span>
                              </div>
                            ))}
                          </div>
                        )}
                        
                        {dish.reasons && (
                          <div className="space-y-1">
                            {dish.reasons.map((reason, idx) => (
                              <div key={idx} className="text-xs text-gray-600 flex items-start gap-1">
                                <span className="text-gray-400 mt-0.5">•</span>
                                <span>{reason}</span>
                              </div>
                            ))}
                          </div>
                        )}
                      </div>
                    </div>
                  </Card>
                ))}
              </div>
            </div>
          );
        })}
      </div>

      {/* Signal Presence Dialog */}
      <Dialog open={showPresenceDialog} onOpenChange={setShowPresenceDialog}>
        <DialogContent className="max-w-md mx-4">
          <DialogHeader>
            <DialogTitle>Signaler ma présence</DialogTitle>
          </DialogHeader>
          
          <div className="space-y-4">
            <p className="text-sm text-gray-600">
              Partagez votre profil culinaire avec le restaurant pour une expérience optimale.
            </p>

            {/* Profile Selection */}
            <Card className="p-4 border-2 border-emerald-200 bg-emerald-50">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-gradient-to-br from-emerald-400 to-teal-500 rounded-full flex items-center justify-center text-white font-semibold">
                  MA
                </div>
                <div className="flex-1">
                  <p className="font-semibold">Mon profil</p>
                  <p className="text-xs text-gray-600">Marie Dupont</p>
                </div>
                <CheckCircle2 className="w-5 h-5 text-emerald-600" />
              </div>
            </Card>

            <button className="text-sm text-emerald-600 hover:text-emerald-700 font-medium">
              + Sélectionner un autre profil
            </button>

            <div className="bg-blue-50 border border-blue-200 rounded-lg p-3">
              <p className="text-xs text-blue-800">
                ℹ️ Le restaurant recevra uniquement vos préférences culinaires et allergies, sans données personnelles sensibles.
              </p>
            </div>

            <div className="flex gap-3">
              <Button 
                variant="outline" 
                className="flex-1"
                onClick={() => setShowPresenceDialog(false)}
              >
                Annuler
              </Button>
              <Button 
                className="flex-1 bg-emerald-600 hover:bg-emerald-700"
                onClick={handleSignalPresence}
              >
                Confirmer
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}
