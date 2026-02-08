import { Leaf } from 'lucide-react';
import { Button } from '../../ui/button';
import { Checkbox } from '../../ui/checkbox';
import { Label } from '../../ui/label';
import { OnboardingData } from '../OnboardingFlow';

interface OnboardingStep4Props {
  data: OnboardingData;
  onUpdate: (updates: Partial<OnboardingData>) => void;
  onNext: () => void;
  onBack: () => void;
}

const dietaryOptions = [
  { value: 'vegetarian', label: 'Végétarien', icon: '🥬' },
  { value: 'vegan', label: 'Végan', icon: '🌱' },
  { value: 'pescatarian', label: 'Pescétarien', icon: '🐟' },
  { value: 'gluten-free', label: 'Sans gluten', icon: '🌾' },
  { value: 'dairy-free', label: 'Sans lactose', icon: '🥛' },
  { value: 'low-carb', label: 'Pauvre en glucides', icon: '🥗' },
  { value: 'keto', label: 'Keto', icon: '🥑' },
  { value: 'halal', label: 'Halal', icon: '☪️' },
  { value: 'kosher', label: 'Casher', icon: '✡️' },
];

export function OnboardingStep4({ data, onUpdate, onNext, onBack }: OnboardingStep4Props) {
  const toggleDietaryRestriction = (restriction: string) => {
    const current = data.dietaryRestrictions || [];
    if (current.includes(restriction)) {
      onUpdate({ dietaryRestrictions: current.filter(r => r !== restriction) });
    } else {
      onUpdate({ dietaryRestrictions: [...current, restriction] });
    }
  };

  return (
    <div className="px-6 py-8 flex flex-col h-full">
      <div className="mb-8">
        <div className="w-16 h-16 bg-gradient-to-br from-emerald-100 to-teal-100 rounded-2xl flex items-center justify-center mb-4">
          <Leaf className="w-8 h-8 text-emerald-600" />
        </div>
        <h2 className="text-2xl font-bold text-gray-900 mb-2">
          Régimes spéciaux
        </h2>
        <p className="text-gray-600">
          Suivez-vous un régime alimentaire particulier ?
        </p>
      </div>

      <div className="flex-1 overflow-y-auto">
        <div className="grid grid-cols-2 gap-3">
          {dietaryOptions.map((option) => (
            <div
              key={option.value}
              className={`p-4 rounded-xl border-2 transition-all cursor-pointer ${
                data.dietaryRestrictions?.includes(option.value)
                  ? 'border-emerald-500 bg-emerald-50'
                  : 'border-gray-200 hover:border-emerald-200'
              }`}
              onClick={() => toggleDietaryRestriction(option.value)}
            >
              <div className="flex flex-col items-center text-center gap-2">
                <span className="text-3xl">{option.icon}</span>
                <span className="text-sm font-medium text-gray-900">
                  {option.label}
                </span>
                {data.dietaryRestrictions?.includes(option.value) && (
                  <span className="text-emerald-600 text-xs">✓</span>
                )}
              </div>
            </div>
          ))}
        </div>

        {data.dietaryRestrictions && data.dietaryRestrictions.length > 0 && (
          <div className="mt-6 p-4 bg-emerald-50 border border-emerald-200 rounded-lg">
            <p className="text-sm text-emerald-800">
              ✓ <span className="font-medium">{data.dietaryRestrictions.length} régime(s) sélectionné(s)</span>
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
