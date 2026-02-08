import { Search, Heart } from 'lucide-react';

interface PlaceholderScreenProps {
  type: 'search' | 'favorites';
}

export function PlaceholderScreen({ type }: PlaceholderScreenProps) {
  const content = {
    search: {
      icon: Search,
      title: "Explorer les plats",
      description: "Recherchez parmi des centaines de plats adaptés à vos besoins"
    },
    favorites: {
      icon: Heart,
      title: "Vos favoris",
      description: "Retrouvez ici tous vos plats préférés pour les commander rapidement"
    }
  };

  const { icon: Icon, title, description } = content[type];

  return (
    <div className="min-h-screen flex items-center justify-center px-4 pb-24">
      <div className="text-center max-w-sm">
        <div className="w-20 h-20 bg-gray-100 rounded-full mx-auto mb-6 flex items-center justify-center">
          <Icon className="w-10 h-10 text-gray-400" />
        </div>
        
        <h2 className="text-2xl font-bold mb-3 text-gray-900">{title}</h2>
        
        <p className="text-gray-500 leading-relaxed">
          {description}
        </p>

        <div className="mt-8 p-4 bg-emerald-50 border border-emerald-200 rounded-lg">
          <p className="text-sm text-emerald-800">
            Cette fonctionnalité sera disponible prochainement
          </p>
        </div>
      </div>
    </div>
  );
}
