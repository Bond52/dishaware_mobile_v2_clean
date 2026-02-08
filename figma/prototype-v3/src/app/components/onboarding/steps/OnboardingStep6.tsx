import { Heart, X } from 'lucide-react';
import { Button } from '../../ui/button';
import { Badge } from '../../ui/badge';
import { Input } from '../../ui/input';
import { Label } from '../../ui/label';
import { OnboardingData } from '../OnboardingFlow';
import { useState } from 'react';

interface OnboardingStep6Props {
  data: OnboardingData;
  onUpdate: (updates: Partial<OnboardingData>) => void;
  onNext: () => void;
  onBack: () => void;
}

const suggestedIngredients = [
  'Avocat', 'Quinoa', 'Saumon', 'Poulet', 'Tomate',
  'Brocoli', 'Carotte', 'Citron', 'Ail', 'Basilic',
  'Parmesan', 'Œufs', 'Champignons', 'Épinards', 'Patate douce',
];

export function OnboardingStep6({ data, onUpdate, onNext, onBack }: OnboardingStep6Props) {
  const [inputValue, setInputValue] = useState('');

  const addIngredient = (ingredient: string) => {
    const current = data.favoriteIngredients || [];
    if (!current.includes(ingredient)) {
      onUpdate({ favoriteIngredients: [...current, ingredient] });
    }
    setInputValue('');
  };

  const removeIngredient = (ingredient: string) => {
    const current = data.favoriteIngredients || [];
    onUpdate({ favoriteIngredients: current.filter(i => i !== ingredient) });
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter' && inputValue.trim()) {
      addIngredient(inputValue.trim());
    }
  };

  return (
    <div className="px-6 py-8 flex flex-col h-full">
      <div className="mb-8">
        <div className="w-16 h-16 bg-gradient-to-br from-rose-100 to-pink-100 rounded-2xl flex items-center justify-center mb-4">
          <Heart className="w-8 h-8 text-rose-600" />
        </div>
        <h2 className="text-2xl font-bold text-gray-900 mb-2">
          Ingrédients favoris
        </h2>
        <p className="text-gray-600">
          Quels ingrédients aimez-vous particulièrement ?
        </p>
      </div>

      <div className="flex-1 overflow-y-auto space-y-6">
        {/* Input */}
        <div>
          <Label htmlFor="ingredient">Ajouter un ingrédient</Label>
          <Input
            id="ingredient"
            type="text"
            placeholder="Ex: Avocat, Quinoa..."
            value={inputValue}
            onChange={(e) => setInputValue(e.target.value)}
            onKeyDown={handleKeyDown}
            className="mt-2"
          />
        </div>

        {/* Selected ingredients */}
        {data.favoriteIngredients && data.favoriteIngredients.length > 0 && (
          <div>
            <h3 className="text-sm font-medium text-gray-700 mb-3">
              Vos ingrédients favoris ({data.favoriteIngredients.length})
            </h3>
            <div className="flex flex-wrap gap-2">
              {data.favoriteIngredients.map((ingredient) => (
                <Badge 
                  key={ingredient} 
                  variant="secondary"
                  className="bg-emerald-100 text-emerald-700 hover:bg-emerald-200 px-3 py-1.5"
                >
                  {ingredient}
                  <button
                    onClick={() => removeIngredient(ingredient)}
                    className="ml-2 hover:text-emerald-900"
                  >
                    <X className="w-3 h-3" />
                  </button>
                </Badge>
              ))}
            </div>
          </div>
        )}

        {/* Suggestions */}
        <div>
          <h3 className="text-sm font-medium text-gray-700 mb-3">
            Suggestions
          </h3>
          <div className="flex flex-wrap gap-2">
            {suggestedIngredients
              .filter(ing => !data.favoriteIngredients?.includes(ing))
              .map((ingredient) => (
                <Badge
                  key={ingredient}
                  variant="outline"
                  className="cursor-pointer hover:bg-emerald-50 hover:border-emerald-300 px-3 py-1.5"
                  onClick={() => addIngredient(ingredient)}
                >
                  + {ingredient}
                </Badge>
              ))}
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
