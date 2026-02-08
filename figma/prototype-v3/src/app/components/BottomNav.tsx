import { Home, Search, Heart, User } from 'lucide-react';

interface BottomNavProps {
  activeTab: string;
  onTabChange: (tab: string) => void;
}

export function BottomNav({ activeTab, onTabChange }: BottomNavProps) {
  const tabs = [
    { id: 'home', label: 'Accueil', icon: Home },
    { id: 'search', label: 'Explorer', icon: Search },
    { id: 'favorites', label: 'Favoris', icon: Heart },
    { id: 'profile', label: 'Profil', icon: User }
  ];

  return (
    <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 safe-area-inset-bottom">
      <div className="max-w-md mx-auto">
        <nav className="flex items-center justify-around px-2 py-2">
          {tabs.map((tab) => {
            const Icon = tab.icon;
            const isActive = activeTab === tab.id;
            
            return (
              <button
                key={tab.id}
                onClick={() => onTabChange(tab.id)}
                className={`flex flex-col items-center justify-center flex-1 py-2 px-3 rounded-lg transition-colors ${
                  isActive 
                    ? 'text-emerald-600' 
                    : 'text-gray-400 hover:text-gray-600'
                }`}
              >
                <Icon className={`w-6 h-6 mb-1 ${isActive ? 'fill-emerald-100' : ''}`} />
                <span className="text-xs font-medium">{tab.label}</span>
              </button>
            );
          })}
        </nav>
      </div>
    </div>
  );
}
