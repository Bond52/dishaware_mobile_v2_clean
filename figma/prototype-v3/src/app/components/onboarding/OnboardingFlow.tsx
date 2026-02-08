import { useState } from 'react';
import { OnboardingProgressBar } from './OnboardingProgressBar';
import { OnboardingStep1 } from './steps/OnboardingStep1';
import { OnboardingStep2 } from './steps/OnboardingStep2';
import { OnboardingStep3 } from './steps/OnboardingStep3';
import { OnboardingStep4 } from './steps/OnboardingStep4';
import { OnboardingStep5 } from './steps/OnboardingStep5';
import { OnboardingStep6 } from './steps/OnboardingStep6';
import { OnboardingStep7 } from './steps/OnboardingStep7';

interface OnboardingFlowProps {
  onComplete: (data: OnboardingData) => void;
  onSkip: () => void;
}

export interface OnboardingData {
  firstName: string;
  lastName: string;
  dailyCalories: number;
  allergies: string[];
  dietaryRestrictions: string[];
  cuisinePreferences: string[];
  favoriteIngredients: string[];
  avoidedIngredients: string[];
  activityLevel: string;
  orderFrequency: string;
}

export function OnboardingFlow({ onComplete, onSkip }: OnboardingFlowProps) {
  const [currentStep, setCurrentStep] = useState(1);
  const totalSteps = 10;

  const [data, setData] = useState<OnboardingData>({
    firstName: '',
    lastName: '',
    dailyCalories: 2000,
    allergies: [],
    dietaryRestrictions: [],
    cuisinePreferences: [],
    favoriteIngredients: [],
    avoidedIngredients: [],
    activityLevel: 'moderate',
    orderFrequency: '3-4-week',
  });

  const updateData = (updates: Partial<OnboardingData>) => {
    setData(prev => ({ ...prev, ...updates }));
  };

  const handleNext = () => {
    if (currentStep < 7) {
      setCurrentStep(prev => prev + 1);
    } else {
      onComplete(data);
    }
  };

  const handleBack = () => {
    if (currentStep > 1) {
      setCurrentStep(prev => prev - 1);
    }
  };

  return (
    <div className="min-h-screen bg-white flex flex-col">
      <OnboardingProgressBar currentStep={currentStep} totalSteps={totalSteps} />

      {/* Skip button */}
      <div className="px-6 py-2 flex justify-end">
        <button 
          onClick={onSkip}
          className="text-sm text-gray-500 hover:text-gray-700 transition-colors"
        >
          Passer →
        </button>
      </div>

      {/* Steps */}
      <div className="flex-1">
        {currentStep === 1 && (
          <OnboardingStep1
            data={data}
            onUpdate={updateData}
            onNext={handleNext}
            onBack={handleBack}
          />
        )}
        {currentStep === 2 && (
          <OnboardingStep2
            data={data}
            onUpdate={updateData}
            onNext={handleNext}
            onBack={handleBack}
          />
        )}
        {currentStep === 3 && (
          <OnboardingStep3
            data={data}
            onUpdate={updateData}
            onNext={handleNext}
            onBack={handleBack}
          />
        )}
        {currentStep === 4 && (
          <OnboardingStep4
            data={data}
            onUpdate={updateData}
            onNext={handleNext}
            onBack={handleBack}
          />
        )}
        {currentStep === 5 && (
          <OnboardingStep5
            data={data}
            onUpdate={updateData}
            onNext={handleNext}
            onBack={handleBack}
          />
        )}
        {currentStep === 6 && (
          <OnboardingStep6
            data={data}
            onUpdate={updateData}
            onNext={handleNext}
            onBack={handleBack}
          />
        )}
        {currentStep === 7 && (
          <OnboardingStep7
            data={data}
            onUpdate={updateData}
            onNext={handleNext}
            onBack={handleBack}
          />
        )}
      </div>
    </div>
  );
}
