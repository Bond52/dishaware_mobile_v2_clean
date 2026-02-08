import { useState } from 'react';
import { HomeScreen } from './components/HomeScreen';
import { ProfileScreen } from './components/ProfileScreen';
import { DishDetailScreen } from './components/DishDetailScreen';
import { FeedbackSuccessScreen } from './components/FeedbackSuccessScreen';
import { PlaceholderScreen } from './components/PlaceholderScreen';
import { RestaurantScreen } from './components/RestaurantScreen';
import { HostModeScreen } from './components/HostModeScreen';
import { ProfileComparisonScreen } from './components/ProfileComparisonScreen';
import { BottomNav } from './components/BottomNav';
import { WelcomeScreen } from './components/onboarding/WelcomeScreen';
import { AuthScreen } from './components/onboarding/AuthScreen';
import { OnboardingFlow, OnboardingData } from './components/onboarding/OnboardingFlow';
import { ProfileConfirmationScreen } from './components/onboarding/ProfileConfirmationScreen';

type Screen = 'welcome' | 'auth' | 'onboarding' | 'profileConfirmation' | 'home' | 'search' | 'favorites' | 'profile' | 'dishDetail' | 'feedbackSuccess' | 'restaurant' | 'hostMode' | 'profileComparison';

export default function App() {
  const [activeScreen, setActiveScreen] = useState<Screen>('welcome');
  const [selectedDishId, setSelectedDishId] = useState<number | null>(null);
  const [feedbackData, setFeedbackData] = useState<{
    type: 'like' | 'dislike';
    level: 'dish' | 'preparation';
  } | null>(null);
  const [onboardingData, setOnboardingData] = useState<OnboardingData | null>(null);

  const handleDishClick = (dishId: number) => {
    setSelectedDishId(dishId);
    setActiveScreen('dishDetail');
  };

  const handleFeedback = (type: 'like' | 'dislike', level: 'dish' | 'preparation') => {
    setFeedbackData({ type, level });
    setActiveScreen('feedbackSuccess');
  };

  const handleFeedbackContinue = () => {
    setActiveScreen('home');
    setFeedbackData(null);
  };

  const handleBackFromDish = () => {
    setActiveScreen('home');
    setSelectedDishId(null);
  };

  const handleTabChange = (tab: string) => {
    setActiveScreen(tab as Screen);
  };

  const handleRestaurantClick = () => {
    setActiveScreen('restaurant');
  };

  const handleHostModeClick = () => {
    setActiveScreen('hostMode');
  };

  const handleCompareProfiles = () => {
    setActiveScreen('profileComparison');
  };

  const handleBackToHome = () => {
    setActiveScreen('home');
  };

  const handleBackToProfile = () => {
    setActiveScreen('profile');
  };

  const handleGetStarted = () => {
    setActiveScreen('auth');
  };

  const handleAuthComplete = () => {
    setActiveScreen('onboarding');
  };

  const handleOnboardingComplete = (data: OnboardingData) => {
    setOnboardingData(data);
    setActiveScreen('profileConfirmation');
  };

  const handleOnboardingSkip = () => {
    setActiveScreen('home');
  };

  const handleProfileConfirm = () => {
    setActiveScreen('home');
  };

  const handleBackToWelcome = () => {
    setActiveScreen('welcome');
  };

  return (
    <div className="min-h-screen bg-white">
      {/* Mobile Container */}
      <div className="max-w-md mx-auto bg-white min-h-screen shadow-xl relative">
        {/* Render active screen */}
        {activeScreen === 'welcome' && (
          <WelcomeScreen onGetStarted={handleGetStarted} />
        )}

        {activeScreen === 'auth' && (
          <AuthScreen 
            onAuthComplete={handleAuthComplete}
            onBack={handleBackToWelcome}
          />
        )}

        {activeScreen === 'onboarding' && (
          <OnboardingFlow 
            onComplete={handleOnboardingComplete}
            onSkip={handleOnboardingSkip}
          />
        )}

        {activeScreen === 'profileConfirmation' && onboardingData && (
          <ProfileConfirmationScreen 
            data={onboardingData}
            onConfirm={handleProfileConfirm}
          />
        )}

        {activeScreen === 'home' && (
          <HomeScreen 
            onDishClick={handleDishClick}
            onRestaurantClick={handleRestaurantClick}
            onHostModeClick={handleHostModeClick}
          />
        )}
        
        {activeScreen === 'search' && <PlaceholderScreen type="search" />}
        
        {activeScreen === 'favorites' && <PlaceholderScreen type="favorites" />}
        
        {activeScreen === 'profile' && (
          <ProfileScreen onCompareProfiles={handleCompareProfiles} />
        )}
        
        {activeScreen === 'restaurant' && (
          <RestaurantScreen 
            onBack={handleBackToHome}
            onDishClick={handleDishClick}
          />
        )}

        {activeScreen === 'hostMode' && (
          <HostModeScreen onBack={handleBackToHome} />
        )}

        {activeScreen === 'profileComparison' && (
          <ProfileComparisonScreen onBack={handleBackToProfile} />
        )}
        
        {activeScreen === 'dishDetail' && selectedDishId && (
          <DishDetailScreen 
            dishId={selectedDishId}
            onBack={handleBackFromDish}
            onFeedback={handleFeedback}
          />
        )}
        
        {activeScreen === 'feedbackSuccess' && feedbackData && (
          <FeedbackSuccessScreen
            feedbackType={feedbackData.type}
            feedbackLevel={feedbackData.level}
            onContinue={handleFeedbackContinue}
          />
        )}

        {/* Bottom Navigation - hide on certain screens */}
        {!['welcome', 'auth', 'onboarding', 'profileConfirmation', 'dishDetail', 'feedbackSuccess', 'restaurant', 'hostMode', 'profileComparison'].includes(activeScreen) && (
          <BottomNav activeTab={activeScreen} onTabChange={handleTabChange} />
        )}
      </div>
    </div>
  );
}