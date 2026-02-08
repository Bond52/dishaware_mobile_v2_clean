import { Activity, Calendar } from 'lucide-react';
import { Button } from '../../ui/button';
import { Label } from '../../ui/label';
import { RadioGroup, RadioGroupItem } from '../../ui/radio-group';
import { OnboardingData } from '../OnboardingFlow';

interface OnboardingStep7Props {
  data: OnboardingData;
  onUpdate: (updates: Partial<OnboardingData>) => void;
  onNext: () => void;
  onBack: () => void;
}

const activityLevels = [
  { value: 'sedentary', label: 'Sédentaire', description: 'Peu ou pas d\'exercice', icon: '🪑' },
  { value: 'light', label: 'Léger', description: '1-3 jours/semaine', icon: '🚶' },
  { value: 'moderate', label: 'Modéré', description: '3-5 jours/semaine', icon: '🏃' },
  { value: 'active', label: 'Actif', description: '6-7 jours/semaine', icon: '💪' },
  { value: 'very-active', label: 'Très actif', description: 'Sport intense quotidien', icon: '🏋️' },
];

const orderFrequencies = [
  { value: '1-week', label: '1 fois par semaine', icon: '📅' },
  { value: '3-4-week', label: '3-4 fois par semaine', icon: '🗓️' },
  { value: 'daily', label: 'Tous les jours', icon: '📆' },
  { value: 'occasional', label: 'Occasionnellement', icon: '🎯' },
];

export function OnboardingStep7({ data, onUpdate, onNext, onBack }: OnboardingStep7Props) {
  return (
    <div className="px-6 py-8 flex flex-col h-full">
      <div className="mb-8">
        <div className="w-16 h-16 bg-gradient-to-br from-blue-100 to-indigo-100 rounded-2xl flex items-center justify-center mb-4">
          <Activity className="w-8 h-8 text-blue-600" />
        </div>
        <h2 className="text-2xl font-bold text-gray-900 mb-2">
          Dernières informations
        </h2>
        <p className="text-gray-600">
          Pour personnaliser au mieux vos recommandations
        </p>
      </div>

      <div className="flex-1 overflow-y-auto space-y-8">
        {/* Activity Level */}
        <div>
          <Label className="text-base mb-4 flex items-center gap-2">
            <Activity className="w-5 h-5 text-emerald-600" />
            Niveau d'activité physique
          </Label>
          <RadioGroup
            value={data.activityLevel}
            onValueChange={(value) => onUpdate({ activityLevel: value })}
            className="space-y-3 mt-4"
          >
            {activityLevels.map((level) => (
              <div
                key={level.value}
                className={`flex items-center space-x-3 p-4 rounded-lg border-2 transition-colors ${
                  data.activityLevel === level.value
                    ? 'border-emerald-500 bg-emerald-50'
                    : 'border-gray-200 hover:border-emerald-200'
                }`}
              >
                <RadioGroupItem value={level.value} id={level.value} />
                <div className="flex items-center gap-3 flex-1">
                  <span className="text-2xl">{level.icon}</span>
                  <div className="flex-1">
                    <Label htmlFor={level.value} className="font-medium cursor-pointer">
                      {level.label}
                    </Label>
                    <p className="text-xs text-gray-500">{level.description}</p>
                  </div>
                </div>
              </div>
            ))}
          </RadioGroup>
        </div>

        {/* Order Frequency */}
        <div>
          <Label className="text-base mb-4 flex items-center gap-2">
            <Calendar className="w-5 h-5 text-emerald-600" />
            Fréquence de commande souhaitée
          </Label>
          <RadioGroup
            value={data.orderFrequency}
            onValueChange={(value) => onUpdate({ orderFrequency: value })}
            className="space-y-3 mt-4"
          >
            {orderFrequencies.map((freq) => (
              <div
                key={freq.value}
                className={`flex items-center space-x-3 p-4 rounded-lg border-2 transition-colors ${
                  data.orderFrequency === freq.value
                    ? 'border-emerald-500 bg-emerald-50'
                    : 'border-gray-200 hover:border-emerald-200'
                }`}
              >
                <RadioGroupItem value={freq.value} id={`freq-${freq.value}`} />
                <div className="flex items-center gap-3 flex-1">
                  <span className="text-2xl">{freq.icon}</span>
                  <Label htmlFor={`freq-${freq.value}`} className="font-medium cursor-pointer flex-1">
                    {freq.label}
                  </Label>
                </div>
              </div>
            ))}
          </RadioGroup>
        </div>
      </div>

      <div className="mt-8 space-y-3">
        <Button 
          onClick={onNext}
          className="w-full bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-700 hover:to-teal-700"
          size="lg"
        >
          Terminer
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
