import { AlertCircle } from 'lucide-react';
import { Button } from '../../ui/button';
import { Checkbox } from '../../ui/checkbox';
import { Label } from '../../ui/label';
import { OnboardingData } from '../OnboardingFlow';

interface OnboardingStep3Props {
  data: OnboardingData;
  onUpdate: (updates: Partial<OnboardingData>) => void;
  onNext: () => void;
  onBack: () => void;
}

const commonAllergies = [
  'Arachides',
  'Fruits à coque',
  'Lait',
  'Œufs',
  'Poisson',
  'Crustacés',
  'Soja',
  'Gluten',
  'Sésame',
  'Moutarde',
  'Sulfites',
];

export function OnboardingStep3({ data, onUpdate, onNext, onBack }: OnboardingStep3Props) {
  const toggleAllergy = (allergy: string) => {
    const current = data.allergies || [];
    if (current.includes(allergy)) {
      onUpdate({ allergies: current.filter(a => a !== allergy) });
    } else {
      onUpdate({ allergies: [...current, allergy] });
    }
  };

  return (
    <div className="px-6 py-8 flex flex-col h-full">
      <div className="mb-8">
        <div className="w-16 h-16 bg-gradient-to-br from-red-100 to-orange-100 rounded-2xl flex items-center justify-center mb-4">
          <AlertCircle className="w-8 h-8 text-red-600" />
        </div>
        <h2 className="text-2xl font-bold text-gray-900 mb-2">
          Allergies alimentaires
        </h2>
        <p className="text-gray-600">
          Sélectionnez vos allergies pour des recommandations adaptées et sécurisées
        </p>
      </div>

      <div className="flex-1 overflow-y-auto">
        <div className="space-y-4">
          {commonAllergies.map((allergy) => (
            <div 
              key={allergy}
              className="flex items-center space-x-3 p-4 rounded-lg border-2 hover:border-emerald-200 transition-colors cursor-pointer"
              onClick={() => toggleAllergy(allergy)}
            >
              <Checkbox
                id={allergy}
                checked={data.allergies?.includes(allergy)}
                onCheckedChange={() => toggleAllergy(allergy)}
              />
              <Label 
                htmlFor={allergy}
                className="flex-1 cursor-pointer"
              >
                {allergy}
              </Label>
            </div>
          ))}
        </div>

        {data.allergies && data.allergies.length > 0 && (
          <div className="mt-6 p-4 bg-emerald-50 border border-emerald-200 rounded-lg">
            <p className="text-sm text-emerald-800">
              ✓ <span className="font-medium">{data.allergies.length} allergie(s) sélectionnée(s)</span>
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
