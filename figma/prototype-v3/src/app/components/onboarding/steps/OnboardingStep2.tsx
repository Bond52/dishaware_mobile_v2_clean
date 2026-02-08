import { Target } from 'lucide-react';
import { Button } from '../../ui/button';
import { Label } from '../../ui/label';
import { Slider } from '../../ui/slider';
import { OnboardingData } from '../OnboardingFlow';

interface OnboardingStep2Props {
  data: OnboardingData;
  onUpdate: (updates: Partial<OnboardingData>) => void;
  onNext: () => void;
  onBack: () => void;
}

export function OnboardingStep2({ data, onUpdate, onNext, onBack }: OnboardingStep2Props) {
  return (
    <div className="px-6 py-8 flex flex-col h-full">
      <div className="mb-8">
        <div className="w-16 h-16 bg-gradient-to-br from-emerald-100 to-teal-100 rounded-2xl flex items-center justify-center mb-4">
          <Target className="w-8 h-8 text-emerald-600" />
        </div>
        <h2 className="text-2xl font-bold text-gray-900 mb-2">
          Votre objectif calorique
        </h2>
        <p className="text-gray-600">
          Définissez votre apport calorique journalier idéal
        </p>
      </div>

      <div className="space-y-8 flex-1">
        <div>
          <div className="flex items-center justify-between mb-4">
            <Label>Calories par jour</Label>
            <div className="text-3xl font-bold text-emerald-600">
              {data.dailyCalories}
            </div>
          </div>
          <Slider
            value={[data.dailyCalories]}
            onValueChange={(values) => onUpdate({ dailyCalories: values[0] })}
            min={1200}
            max={3500}
            step={50}
            className="w-full"
          />
          <div className="flex justify-between text-xs text-gray-500 mt-2">
            <span>1200</span>
            <span>3500</span>
          </div>
        </div>

        {/* Info cards */}
        <div className="space-y-3">
          <div className="p-4 bg-blue-50 border border-blue-200 rounded-lg">
            <p className="text-sm text-blue-800">
              💡 <span className="font-medium">Conseil :</span> La moyenne se situe entre 1800-2400 kcal/jour selon votre activité
            </p>
          </div>
        </div>
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
