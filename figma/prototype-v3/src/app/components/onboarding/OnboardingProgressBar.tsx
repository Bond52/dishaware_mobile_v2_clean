interface OnboardingProgressBarProps {
  currentStep: number;
  totalSteps: number;
}

export function OnboardingProgressBar({ currentStep, totalSteps }: OnboardingProgressBarProps) {
  const progressPercentage = (currentStep / totalSteps) * 100;

  return (
    <div className="px-6 pt-6 pb-4">
      <div className="flex items-center justify-between mb-2">
        <span className="text-sm font-medium text-gray-700">
          Étape {currentStep} sur {totalSteps}
        </span>
        <span className="text-sm text-gray-500">
          {Math.round(progressPercentage)}%
        </span>
      </div>
      <div className="w-full bg-gray-200 rounded-full h-2">
        <div 
          className="bg-gradient-to-r from-emerald-500 to-teal-600 h-2 rounded-full transition-all duration-300"
          style={{ width: `${progressPercentage}%` }}
        />
      </div>
    </div>
  );
}
