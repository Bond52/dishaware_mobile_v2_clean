import { CheckCircle, Sparkles } from 'lucide-react';
import { Button } from '../ui/button';
import { Card } from '../ui/card';
import { OnboardingData } from './OnboardingFlow';

interface ProfileConfirmationScreenProps {
  data: OnboardingData;
  onConfirm: () => void;
}

export function ProfileConfirmationScreen({ data, onConfirm }: ProfileConfirmationScreenProps) {
  return (
    <div className="min-h-screen bg-gradient-to-br from-emerald-50 via-teal-50 to-white flex flex-col px-6 py-12">
      {/* Success Icon */}
      <div className="flex flex-col items-center mb-8">
        <div className="relative mb-6">
          <div className="w-24 h-24 bg-gradient-to-br from-emerald-500 to-teal-600 rounded-full flex items-center justify-center shadow-2xl">
            <CheckCircle className="w-14 h-14 text-white" />
          </div>
          <div className="absolute -bottom-2 -right-2">
            <div className="w-10 h-10 bg-yellow-400 rounded-full flex items-center justify-center animate-pulse">
              <Sparkles className="w-6 h-6 text-yellow-600" />
            </div>
          </div>
        </div>

        <h1 className="text-3xl font-bold text-gray-900 mb-3 text-center">
          Profil créé avec succès !
        </h1>
        <p className="text-gray-600 text-center max-w-sm">
          Bienvenue {data.firstName}, votre expérience personnalisée vous attend
        </p>
      </div>

      {/* Profile Summary */}
      <div className="space-y-4 mb-8 flex-1">
        <Card className="p-4 bg-white border-emerald-200">
          <div className="flex items-center gap-3 mb-3">
            <div className="w-10 h-10 bg-emerald-100 rounded-full flex items-center justify-center">
              <span className="text-lg">🎯</span>
            </div>
            <div>
              <h3 className="font-medium text-gray-900">Objectif journalier</h3>
              <p className="text-sm text-gray-600">{data.dailyCalories} kcal/jour</p>
            </div>
          </div>
        </Card>

        {data.dietaryRestrictions && data.dietaryRestrictions.length > 0 && (
          <Card className="p-4 bg-white border-emerald-200">
            <div className="flex items-center gap-3 mb-3">
              <div className="w-10 h-10 bg-emerald-100 rounded-full flex items-center justify-center">
                <span className="text-lg">🌱</span>
              </div>
              <div>
                <h3 className="font-medium text-gray-900">Régimes alimentaires</h3>
                <p className="text-sm text-gray-600">
                  {data.dietaryRestrictions.length} sélectionné(s)
                </p>
              </div>
            </div>
          </Card>
        )}

        {data.cuisinePreferences && data.cuisinePreferences.length > 0 && (
          <Card className="p-4 bg-white border-emerald-200">
            <div className="flex items-center gap-3 mb-3">
              <div className="w-10 h-10 bg-emerald-100 rounded-full flex items-center justify-center">
                <span className="text-lg">🌍</span>
              </div>
              <div>
                <h3 className="font-medium text-gray-900">Cuisines favorites</h3>
                <p className="text-sm text-gray-600">
                  {data.cuisinePreferences.length} sélectionnée(s)
                </p>
              </div>
            </div>
          </Card>
        )}

        {data.allergies && data.allergies.length > 0 && (
          <Card className="p-4 bg-white border-red-200">
            <div className="flex items-center gap-3 mb-3">
              <div className="w-10 h-10 bg-red-100 rounded-full flex items-center justify-center">
                <span className="text-lg">⚠️</span>
              </div>
              <div>
                <h3 className="font-medium text-gray-900">Allergies</h3>
                <p className="text-sm text-gray-600">
                  {data.allergies.length} allergie(s) enregistrée(s)
                </p>
              </div>
            </div>
          </Card>
        )}

        {/* Info card */}
        <Card className="p-4 bg-gradient-to-br from-emerald-50 to-teal-50 border-emerald-200">
          <div className="flex gap-3">
            <div className="flex-shrink-0">
              <Sparkles className="w-5 h-5 text-emerald-600" />
            </div>
            <div>
              <p className="text-sm text-emerald-800 leading-relaxed">
                Notre IA analyse vos préférences pour vous proposer des recommandations parfaitement adaptées à vos goûts et à vos besoins nutritionnels.
              </p>
            </div>
          </div>
        </Card>
      </div>

      {/* CTA Button */}
      <Button 
        onClick={onConfirm}
        size="lg"
        className="w-full bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-700 hover:to-teal-700 text-white shadow-lg"
      >
        Découvrir mes recommandations
      </Button>
    </div>
  );
}
