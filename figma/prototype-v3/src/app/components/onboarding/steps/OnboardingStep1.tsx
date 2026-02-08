import { User } from 'lucide-react';
import { Button } from '../../ui/button';
import { Input } from '../../ui/input';
import { Label } from '../../ui/label';
import { OnboardingData } from '../OnboardingFlow';

interface OnboardingStep1Props {
  data: OnboardingData;
  onUpdate: (updates: Partial<OnboardingData>) => void;
  onNext: () => void;
  onBack: () => void;
}

export function OnboardingStep1({ data, onUpdate, onNext }: OnboardingStep1Props) {
  const canContinue = data.firstName.trim() !== '' && data.lastName.trim() !== '';

  return (
    <div className="px-6 py-8 flex flex-col h-full">
      <div className="mb-8">
        <div className="w-16 h-16 bg-gradient-to-br from-emerald-100 to-teal-100 rounded-2xl flex items-center justify-center mb-4">
          <User className="w-8 h-8 text-emerald-600" />
        </div>
        <h2 className="text-2xl font-bold text-gray-900 mb-2">
          Faisons connaissance
        </h2>
        <p className="text-gray-600">
          Comment souhaitez-vous qu'on vous appelle ?
        </p>
      </div>

      <div className="space-y-6 flex-1">
        <div>
          <Label htmlFor="firstName">Prénom</Label>
          <Input
            id="firstName"
            type="text"
            placeholder="Marie"
            value={data.firstName}
            onChange={(e) => onUpdate({ firstName: e.target.value })}
            className="mt-2"
          />
        </div>

        <div>
          <Label htmlFor="lastName">Nom</Label>
          <Input
            id="lastName"
            type="text"
            placeholder="Dupont"
            value={data.lastName}
            onChange={(e) => onUpdate({ lastName: e.target.value })}
            className="mt-2"
          />
        </div>
      </div>

      <div className="mt-8">
        <Button 
          onClick={onNext}
          disabled={!canContinue}
          className="w-full bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-700 hover:to-teal-700 disabled:opacity-50 disabled:cursor-not-allowed"
          size="lg"
        >
          Continuer
        </Button>
      </div>
    </div>
  );
}
