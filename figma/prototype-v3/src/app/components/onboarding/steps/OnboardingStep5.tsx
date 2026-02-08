import { Globe } from 'lucide-react';
import { Button } from '../../ui/button';
import { OnboardingData } from '../OnboardingFlow';

interface OnboardingStep5Props {
  data: OnboardingData;
  onUpdate: (updates: Partial<OnboardingData>) => void;
  onNext: () => void;
  onBack: () => void;
}

const cuisineTypes = [
  { value: 'french', label: 'Française', icon: '🥖' },
  { value: 'italian', label: 'Italienne', icon: '🍝' },
  { value: 'japanese', label: 'Japonaise', icon: '🍱' },
  { value: 'chinese', label: 'Chinoise', icon: '🥢' },
  { value: 'indian', label: 'Indienne', icon: '🍛' },
  { value: 'mexican', label: 'Mexicaine', icon: '🌮' },
  { value: 'thai', label: 'Thaïlandaise', icon: '🍜' },
  { value: 'mediterranean', label: 'Méditerranéenne', icon: '🫒' },
  { value: 'american', label: 'Américaine', icon: '🍔' },
  { value: 'korean', label: 'Coréenne', icon: '🍲' },
  { value: 'lebanese', label: 'Libanaise', icon: '🧆' },
  { value: 'vietnamese', label: 'Vietnamienne', icon: '🥗' },
];

export function OnboardingStep5({ data, onUpdate, onNext, onBack }: OnboardingStep5Props) {
  const toggleCuisine = (cuisine: string) => {
    const current = data.cuisinePreferences || [];
    if (current.includes(cuisine)) {
      onUpdate({ cuisinePreferences: current.filter(c => c !== cuisine) });
    } else {
      onUpdate({ cuisinePreferences: [...current, cuisine] });
    }
  };

  return (
    <div className="px-6 py-8 flex flex-col h-full">
      <div className="mb-8">
        <div className="w-16 h-16 bg-gradient-to-br from-purple-100 to-pink-100 rounded-2xl flex items-center justify-center mb-4">
          <Globe className="w-8 h-8 text-purple-600" />
        </div>
        <h2 className="text-2xl font-bold text-gray-900 mb-2">
          Vos cuisines préférées
        </h2>
        <p className="text-gray-600">
          Quelles cuisines du monde aimez-vous explorer ?
        </p>
      </div>

      <div className="flex-1 overflow-y-auto">
        <div className="grid grid-cols-2 gap-3">
          {cuisineTypes.map((cuisine) => (
            <div
              key={cuisine.value}
              className={`p-4 rounded-xl border-2 transition-all cursor-pointer ${
                data.cuisinePreferences?.includes(cuisine.value)
                  ? 'border-emerald-500 bg-emerald-50'
                  : 'border-gray-200 hover:border-emerald-200'
              }`}
              onClick={() => toggleCuisine(cuisine.value)}
            >
              <div className="flex flex-col items-center text-center gap-2">
                <span className="text-3xl">{cuisine.icon}</span>
                <span className="text-sm font-medium text-gray-900">
                  {cuisine.label}
                </span>
                {data.cuisinePreferences?.includes(cuisine.value) && (
                  <span className="text-emerald-600 text-xs">✓</span>
                )}
              </div>
            </div>
          ))}
        </div>

        {data.cuisinePreferences && data.cuisinePreferences.length > 0 && (
          <div className="mt-6 p-4 bg-emerald-50 border border-emerald-200 rounded-lg">
            <p className="text-sm text-emerald-800">
              ✓ <span className="font-medium">{data.cuisinePreferences.length} cuisine(s) sélectionnée(s)</span>
            </p>
          </div>
        )}
      </div>

      <div className="mt-8 space-y-3">
        <Button 
          onClick={onNext}
          className="w-full bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-700 hover:to-teal-700"
          size="lg"
        >
          Continuer
        </Button>
        <Button 
          onClick={onBack}
          variant="ghost"
          className="w-full"
          size="lg"
        >
          Retour
        </Button>
      </div>
    </div>
  );
}
