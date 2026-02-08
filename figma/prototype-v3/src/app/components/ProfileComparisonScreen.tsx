import { ArrowLeft, Users, CheckCircle2, XCircle, AlertCircle } from 'lucide-react';
import { Card } from './ui/card';
import { Button } from './ui/button';

interface ProfileComparisonScreenProps {
  onBack: () => void;
}

export function ProfileComparisonScreen({ onBack }: ProfileComparisonScreenProps) {
  const comparison = {
    user1: {
      name: "Marie Dupont",
      initials: "MA",
      allergies: ["Arachides", "Fruits à coque", "Crustacés"],
      preferences: ["Végétarien", "Méditerranéen", "Faible en sodium"],
      likes: ["Carotte + Citron", "Quinoa", "Avocat"],
      dislikes: ["Épicé fort", "Fromage fort"]
    },
    user2: {
      name: "Thomas Martin",
      initials: "TM",
      allergies: ["Lactose"],
      preferences: ["Riche en protéines", "Asiatique", "Épicé"],
      likes: ["Poulet", "Riz", "Gingembre"],
      dislikes: ["Poisson cru", "Champignons"]
    }
  };

  const analysis = {
    compatibility: 68,
    commonAllergies: [],
    commonPreferences: [],
    commonLikes: [],
    conflicts: [
      {
        type: 'preference',
        detail: "Marie est végétarienne, Thomas préfère les plats riches en protéines animales"
      },
      {
        type: 'taste',
        detail: "Marie évite l'épicé fort, Thomas aime les plats épicés"
      }
    ],
    recommendations: [
      "Plats végétariens riches en protéines (tofu, légumineuses)",
      "Cuisine méditerranéenne avec option épices à part",
      "Éviter : lactose, arachides, fruits à coque"
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
            <h1 className="font-semibold text-lg">Comparaison de profils</h1>
            <p className="text-xs text-gray-500">Analyse de compatibilité</p>
          </div>
        </div>
      </div>

      <div className="px-4 pt-4">
        {/* Profiles Being Compared */}
        <div className="mb-6 flex gap-3">
          <Card className="flex-1 p-4 text-center bg-gradient-to-br from-emerald-50 to-emerald-100 border-emerald-200">
            <div className="w-16 h-16 bg-gradient-to-br from-emerald-400 to-teal-500 rounded-full mx-auto mb-2 flex items-center justify-center text-white text-lg font-semibold">
              {comparison.user1.initials}
            </div>
            <p className="font-semibold text-sm">{comparison.user1.name}</p>
          </Card>

          <div className="flex items-center justify-center px-2">
            <Users className="w-6 h-6 text-gray-400" />
          </div>

          <Card className="flex-1 p-4 text-center bg-gradient-to-br from-blue-50 to-blue-100 border-blue-200">
            <div className="w-16 h-16 bg-gradient-to-br from-blue-400 to-indigo-500 rounded-full mx-auto mb-2 flex items-center justify-center text-white text-lg font-semibold">
              {comparison.user2.initials}
            </div>
            <p className="font-semibold text-sm">{comparison.user2.name}</p>
          </Card>
        </div>

        {/* Compatibility Score */}
        <Card className="mb-6 p-6 bg-gradient-to-br from-purple-50 to-pink-50 border-purple-200">
          <div className="text-center">
            <div className="inline-flex items-center justify-center w-24 h-24 rounded-full bg-white shadow-lg mb-3">
              <div className="text-center">
                <div className="text-3xl font-bold text-purple-600">{analysis.compatibility}%</div>
                <div className="text-xs text-gray-500">compatible</div>
              </div>
            </div>
            <p className="text-sm text-gray-700">
              Compatibilité culinaire modérée. Plusieurs options de menu possibles avec ajustements.
            </p>
          </div>
        </Card>

        {/* Allergies Comparison */}
        <div className="mb-6">
          <h3 className="font-semibold mb-3">Allergies</h3>
          <div className="grid grid-cols-2 gap-3">
            <Card className="p-4">
              <p className="text-xs font-medium text-gray-500 mb-2">{comparison.user1.name}</p>
              <div className="space-y-1.5">
                {comparison.user1.allergies.map((allergy) => (
                  <div key={allergy} className="flex items-center gap-2 text-sm">
                    <div className="w-1.5 h-1.5 rounded-full bg-red-500"></div>
                    <span className="text-gray-700">{allergy}</span>
                  </div>
                ))}
              </div>
            </Card>

            <Card className="p-4">
              <p className="text-xs font-medium text-gray-500 mb-2">{comparison.user2.name}</p>
              <div className="space-y-1.5">
                {comparison.user2.allergies.map((allergy) => (
                  <div key={allergy} className="flex items-center gap-2 text-sm">
                    <div className="w-1.5 h-1.5 rounded-full bg-red-500"></div>
                    <span className="text-gray-700">{allergy}</span>
                  </div>
                ))}
              </div>
            </Card>
          </div>

          <div className="mt-3 p-3 bg-green-50 border border-green-200 rounded-lg">
            <div className="flex items-start gap-2">
              <CheckCircle2 className="w-4 h-4 text-green-600 mt-0.5 flex-shrink-0" />
              <p className="text-sm text-green-800">
                Aucune allergie commune • Les deux profils peuvent partager un repas en évitant tous les allergènes listés
              </p>
            </div>
          </div>
        </div>

        {/* Preferences Comparison */}
        <div className="mb-6">
          <h3 className="font-semibold mb-3">Préférences alimentaires</h3>
          <div className="grid grid-cols-2 gap-3">
            <Card className="p-4">
              <p className="text-xs font-medium text-gray-500 mb-2">{comparison.user1.name}</p>
              <div className="space-y-1.5">
                {comparison.user1.preferences.map((pref) => (
                  <div key={pref} className="px-2 py-1 bg-emerald-50 border border-emerald-200 rounded text-xs text-emerald-700">
                    {pref}
                  </div>
                ))}
              </div>
            </Card>

            <Card className="p-4">
              <p className="text-xs font-medium text-gray-500 mb-2">{comparison.user2.name}</p>
              <div className="space-y-1.5">
                {comparison.user2.preferences.map((pref) => (
                  <div key={pref} className="px-2 py-1 bg-blue-50 border border-blue-200 rounded text-xs text-blue-700">
                    {pref}
                  </div>
                ))}
              </div>
            </Card>
          </div>
        </div>

        {/* Conflicts */}
        <div className="mb-6">
          <h3 className="font-semibold mb-3 flex items-center gap-2">
            <AlertCircle className="w-5 h-5 text-orange-600" />
            Points de divergence
          </h3>
          <div className="space-y-3">
            {analysis.conflicts.map((conflict, idx) => (
              <Card key={idx} className="p-4 bg-orange-50 border-orange-200">
                <div className="flex items-start gap-3">
                  <XCircle className="w-5 h-5 text-orange-600 flex-shrink-0 mt-0.5" />
                  <div>
                    <p className="text-xs font-medium text-orange-900 mb-1 uppercase">
                      {conflict.type === 'preference' ? 'Préférence' : 'Goût'}
                    </p>
                    <p className="text-sm text-orange-800">{conflict.detail}</p>
                  </div>
                </div>
              </Card>
            ))}
          </div>
        </div>

        {/* Taste Preferences */}
        <div className="mb-6">
          <h3 className="font-semibold mb-3">Saveurs préférées</h3>
          <div className="grid grid-cols-2 gap-3">
            <Card className="p-4">
              <p className="text-xs font-medium text-gray-500 mb-2">{comparison.user1.name}</p>
              <div className="space-y-1">
                {comparison.user1.likes.map((like) => (
                  <div key={like} className="text-sm text-gray-700 flex items-start gap-1.5">
                    <span className="text-emerald-500 mt-1">♥</span>
                    <span>{like}</span>
                  </div>
                ))}
              </div>
            </Card>

            <Card className="p-4">
              <p className="text-xs font-medium text-gray-500 mb-2">{comparison.user2.name}</p>
              <div className="space-y-1">
                {comparison.user2.likes.map((like) => (
                  <div key={like} className="text-sm text-gray-700 flex items-start gap-1.5">
                    <span className="text-blue-500 mt-1">♥</span>
                    <span>{like}</span>
                  </div>
                ))}
              </div>
            </Card>
          </div>
        </div>

        {/* Recommendations */}
        <Card className="mb-6 p-4 bg-gradient-to-br from-emerald-50 to-teal-50 border-emerald-200">
          <h3 className="font-semibold mb-3 text-emerald-900">Recommandations pour un menu compatible</h3>
          <div className="space-y-2">
            {analysis.recommendations.map((rec, idx) => (
              <div key={idx} className="flex items-start gap-2 text-sm text-emerald-800">
                <CheckCircle2 className="w-4 h-4 flex-shrink-0 mt-0.5 text-emerald-600" />
                <span>{rec}</span>
              </div>
            ))}
          </div>
        </Card>

        {/* Actions */}
        <div className="flex gap-3">
          <Button 
            variant="outline"
            className="flex-1"
            onClick={onBack}
          >
            Retour
          </Button>
          <Button 
            className="flex-1 bg-emerald-600 hover:bg-emerald-700"
          >
            Voir les plats compatibles
          </Button>
        </div>
      </div>
    </div>
  );
}
