import { useState } from 'react';
import { ArrowLeft, Users, Upload, CheckCircle2, AlertTriangle, Heart, ChefHat } from 'lucide-react';
import { Card } from './ui/card';
import { Button } from './ui/button';

interface HostModeScreenProps {
  onBack: () => void;
}

interface GuestProfile {
  id: number;
  name: string;
  initials: string;
  allergies: string[];
  preferences: string[];
  dislikes: string[];
}

export function HostModeScreen({ onBack }: HostModeScreenProps) {
  const [step, setStep] = useState<'upload' | 'analysis' | 'menu'>('upload');
  const [guests, setGuests] = useState<GuestProfile[]>([
    {
      id: 1,
      name: "Marie Dupont",
      initials: "MA",
      allergies: ["Arachides", "Fruits à coque"],
      preferences: ["Végétarien", "Méditerranéen"],
      dislikes: ["Épicé fort"]
    },
    {
      id: 2,
      name: "Thomas Martin",
      initials: "TM",
      allergies: ["Lactose"],
      preferences: ["Riche en protéines", "Asiatique"],
      dislikes: ["Poisson cru"]
    },
    {
      id: 3,
      name: "Sophie Bernard",
      initials: "SB",
      allergies: [],
      preferences: ["Sans gluten", "Végétarien"],
      dislikes: ["Champignons"]
    }
  ]);

  const menuSuggestions = [
    {
      id: 1,
      name: "Bowl Méditerranéen au Quinoa",
      calories: 420,
      image: "https://images.unsplash.com/photo-1623428187969-5da2dcea5ebf?w=400&h=300&fit=crop",
      compatibility: 100,
      reasons: [
        "✓ Sans allergènes pour tous",
        "✓ Végétarien (Marie & Sophie)",
        "✓ Sans gluten naturellement (Sophie)",
        "✓ Protéines équilibrées (Thomas)"
      ]
    },
    {
      id: 2,
      name: "Légumes Grillés, Sauce Tahini",
      calories: 280,
      image: "https://images.unsplash.com/photo-1572449043416-55f4685c9bb7?w=400&h=300&fit=crop",
      compatibility: 100,
      reasons: [
        "✓ Convient à tous les régimes",
        "✓ Sans lactose (Thomas)",
        "✓ Végétarien (Marie & Sophie)"
      ]
    },
    {
      id: 3,
      name: "Poulet Rôti aux Herbes",
      calories: 380,
      image: "https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=400&h=300&fit=crop",
      compatibility: 67,
      reasons: [
        "✓ Sans allergènes",
        "✓ Riche en protéines (Thomas)",
        "⚠ Pas végétarien (compromis pour Marie & Sophie)"
      ]
    }
  ];

  const groupAnalysis = {
    totalGuests: guests.length,
    commonAllergies: ["Arachides", "Fruits à coque", "Lactose"],
    commonPreferences: ["Végétarien"],
    challenges: [
      "2/3 personnes végétariennes",
      "Plusieurs allergies à considérer",
      "Préférences de cuisine variées"
    ]
  };

  return (
    <div className="pb-24">
      {/* Header */}
      <div className="sticky top-0 z-10 bg-white border-b px-4 py-3">
        <div className="flex items-center gap-3">
          <button 
            onClick={onBack}
            className="w-9 h-9 rounded-full bg-gray-100 flex items-center justify-center hover:bg-gray-200"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div className="flex-1">
            <h1 className="font-semibold text-lg">Mode Hôte</h1>
            <p className="text-xs text-gray-500">Menu pour plusieurs invités</p>
          </div>
        </div>
      </div>

      <div className="px-4 pt-4">
        {/* Step Indicator */}
        <div className="mb-6 flex items-center justify-between">
          {['Invités', 'Analyse', 'Menu'].map((label, idx) => {
            const stepNumber = idx + 1;
            const isActive = 
              (step === 'upload' && stepNumber === 1) ||
              (step === 'analysis' && stepNumber === 2) ||
              (step === 'menu' && stepNumber === 3);
            const isCompleted = 
              (step === 'analysis' && stepNumber === 1) ||
              (step === 'menu' && stepNumber <= 2);

            return (
              <div key={label} className="flex-1 flex flex-col items-center">
                <div className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-semibold mb-1 ${
                  isCompleted ? 'bg-emerald-600 text-white' :
                  isActive ? 'bg-emerald-100 text-emerald-700 border-2 border-emerald-600' :
                  'bg-gray-100 text-gray-400'
                }`}>
                  {isCompleted ? <CheckCircle2 className="w-5 h-5" /> : stepNumber}
                </div>
                <span className={`text-xs ${isActive || isCompleted ? 'text-gray-900 font-medium' : 'text-gray-400'}`}>
                  {label}
                </span>
              </div>
            );
          })}
        </div>

        {/* Upload Step */}
        {step === 'upload' && (
          <div className="space-y-4">
            <Card className="p-6 text-center border-2 border-dashed border-emerald-200 bg-emerald-50/50">
              <div className="w-16 h-16 bg-emerald-100 rounded-full mx-auto mb-4 flex items-center justify-center">
                <Upload className="w-8 h-8 text-emerald-600" />
              </div>
              <h3 className="font-semibold mb-2">Importer des profils</h3>
              <p className="text-sm text-gray-600 mb-4">
                Ajoutez les profils culinaires de vos invités pour générer un menu adapté à tous
              </p>
              <Button variant="outline" className="border-emerald-600 text-emerald-600 hover:bg-emerald-50">
                Parcourir les fichiers
              </Button>
            </Card>

            <div className="mb-4">
              <div className="flex items-center justify-between mb-3">
                <h3 className="font-semibold">Invités ajoutés ({guests.length})</h3>
                <button className="text-sm text-emerald-600 hover:text-emerald-700 font-medium">
                  + Ajouter
                </button>
              </div>

              <div className="space-y-3">
                {guests.map((guest) => (
                  <Card key={guest.id} className="p-4">
                    <div className="flex items-start gap-3">
                      <div className="w-12 h-12 bg-gradient-to-br from-emerald-400 to-teal-500 rounded-full flex items-center justify-center text-white font-semibold">
                        {guest.initials}
                      </div>
                      <div className="flex-1">
                        <p className="font-semibold mb-1">{guest.name}</p>
                        <div className="space-y-1 text-xs">
                          {guest.allergies.length > 0 && (
                            <p className="text-red-600">
                              🚫 {guest.allergies.join(', ')}
                            </p>
                          )}
                          {guest.preferences.length > 0 && (
                            <p className="text-emerald-600">
                              ✓ {guest.preferences.join(', ')}
                            </p>
                          )}
                        </div>
                      </div>
                    </div>
                  </Card>
                ))}
              </div>
            </div>

            <Button 
              className="w-full bg-emerald-600 hover:bg-emerald-700 py-6"
              onClick={() => setStep('analysis')}
            >
              Analyser le groupe
            </Button>
          </div>
        )}

        {/* Analysis Step */}
        {step === 'analysis' && (
          <div className="space-y-4">
            <Card className="p-6 bg-gradient-to-br from-emerald-50 to-teal-50 border-emerald-200">
              <div className="flex items-start gap-3 mb-4">
                <div className="w-12 h-12 bg-emerald-100 rounded-full flex items-center justify-center">
                  <Users className="w-6 h-6 text-emerald-600" />
                </div>
                <div>
                  <h3 className="font-semibold text-lg mb-1">Résumé du groupe</h3>
                  <p className="text-sm text-gray-600">{groupAnalysis.totalGuests} invités</p>
                </div>
              </div>

              <div className="grid grid-cols-3 gap-3 text-center mb-4">
                <div className="bg-white/80 rounded-lg p-3">
                  <div className="text-2xl font-bold text-red-600">{groupAnalysis.commonAllergies.length}</div>
                  <div className="text-xs text-gray-600 mt-1">Allergies</div>
                </div>
                <div className="bg-white/80 rounded-lg p-3">
                  <div className="text-2xl font-bold text-emerald-600">{groupAnalysis.commonPreferences.length}</div>
                  <div className="text-xs text-gray-600 mt-1">Préférence commune</div>
                </div>
                <div className="bg-white/80 rounded-lg p-3">
                  <div className="text-2xl font-bold text-blue-600">8</div>
                  <div className="text-xs text-gray-600 mt-1">Plats compatibles</div>
                </div>
              </div>
            </Card>

            {/* Common Allergies */}
            <div>
              <h3 className="font-semibold mb-3 flex items-center gap-2">
                <AlertTriangle className="w-5 h-5 text-red-600" />
                Allergies à respecter
              </h3>
              <Card className="p-4">
                <div className="flex flex-wrap gap-2">
                  {groupAnalysis.commonAllergies.map((allergy) => (
                    <span 
                      key={allergy}
                      className="px-3 py-1.5 bg-red-50 text-red-700 rounded-full text-sm border border-red-200"
                    >
                      {allergy}
                    </span>
                  ))}
                </div>
              </Card>
            </div>

            {/* Common Preferences */}
            <div>
              <h3 className="font-semibold mb-3 flex items-center gap-2">
                <Heart className="w-5 h-5 text-emerald-600" />
                Préférences communes
              </h3>
              <Card className="p-4">
                <div className="flex flex-wrap gap-2">
                  {groupAnalysis.commonPreferences.map((pref) => (
                    <span 
                      key={pref}
                      className="px-3 py-1.5 bg-emerald-50 text-emerald-700 rounded-full text-sm border border-emerald-200"
                    >
                      {pref}
                    </span>
                  ))}
                </div>
              </Card>
            </div>

            {/* Challenges */}
            <Card className="p-4 bg-blue-50 border-blue-200">
              <h4 className="font-medium text-blue-900 mb-2">Points d'attention</h4>
              <ul className="space-y-2">
                {groupAnalysis.challenges.map((challenge, idx) => (
                  <li key={idx} className="text-sm text-blue-800 flex items-start gap-2">
                    <span className="text-blue-400 mt-1">•</span>
                    <span>{challenge}</span>
                  </li>
                ))}
              </ul>
            </Card>

            <Button 
              className="w-full bg-emerald-600 hover:bg-emerald-700 py-6"
              onClick={() => setStep('menu')}
            >
              Générer le menu
            </Button>
          </div>
        )}

        {/* Menu Step */}
        {step === 'menu' && (
          <div className="space-y-4">
            <Card className="p-4 bg-gradient-to-r from-emerald-500 to-teal-500 text-white">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center">
                  <ChefHat className="w-6 h-6" />
                </div>
                <div className="flex-1">
                  <h3 className="font-semibold mb-1">Menu généré</h3>
                  <p className="text-sm text-white/90">
                    {menuSuggestions.length} plats compatibles avec votre groupe
                  </p>
                </div>
              </div>
            </Card>

            <div className="space-y-4">
              {menuSuggestions.map((dish) => (
                <Card key={dish.id} className="overflow-hidden">
                  <div className="flex gap-3">
                    <img 
                      src={dish.image}
                      alt={dish.name}
                      className="w-28 h-28 object-cover flex-shrink-0"
                    />
                    <div className="flex-1 p-3">
                      <div className="flex items-start justify-between mb-1">
                        <h4 className="font-semibold text-sm pr-2">{dish.name}</h4>
                        <div className={`px-2 py-1 rounded-full text-xs font-semibold flex-shrink-0 ${
                          dish.compatibility === 100 ? 'bg-emerald-100 text-emerald-700' :
                          dish.compatibility >= 70 ? 'bg-blue-100 text-blue-700' :
                          'bg-yellow-100 text-yellow-700'
                        }`}>
                          {dish.compatibility}%
                        </div>
                      </div>
                      <p className="text-xs text-gray-500 mb-2">{dish.calories} kcal</p>
                    </div>
                  </div>
                  
                  <div className="px-4 pb-4">
                    <div className="bg-gray-50 rounded-lg p-3 space-y-1">
                      {dish.reasons.map((reason, idx) => (
                        <p key={idx} className="text-xs text-gray-700">
                          {reason}
                        </p>
                      ))}
                    </div>
                  </div>
                </Card>
              ))}
            </div>

            <div className="flex gap-3">
              <Button 
                variant="outline"
                className="flex-1"
                onClick={() => setStep('upload')}
              >
                Modifier le groupe
              </Button>
              <Button 
                className="flex-1 bg-emerald-600 hover:bg-emerald-700"
              >
                Confirmer le menu
              </Button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
