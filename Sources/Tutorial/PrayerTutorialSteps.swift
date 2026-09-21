import Foundation

enum Posture {
    case standing, bowing, prostrate, sitting
}

struct TutorialStep: Identifiable {
    let id: Int
    let title: String
    let instruction: String
    let posture: Posture
}

enum PrayerTutorial {
    // A simplified walkthrough of one rak'ah's core movements — an overview
    // for learning the shape of the prayer, not a complete fıqh reference.
    static let steps: [TutorialStep] = [
        TutorialStep(id: 1, title: "Niyet", instruction: "Kalben hangi namazı kılacağına niyet et. Kıbleye dön.", posture: .standing),
        TutorialStep(id: 2, title: "İftitah Tekbiri", instruction: "Ellerini kaldırıp \"Allahu Ekber\" diyerek namaza başla.", posture: .standing),
        TutorialStep(id: 3, title: "Kıyam", instruction: "Elini bağlayıp Fatiha Suresi'ni ve ardından bir sure oku.", posture: .standing),
        TutorialStep(id: 4, title: "Rükû", instruction: "Eğilip ellerini dizlerine koy, sırtını düz tut. Üç kez \"Sübhâne rabbiyel azîm\" de.", posture: .bowing),
        TutorialStep(id: 5, title: "Kavme", instruction: "Doğrulup \"Semi'allâhu limen hamideh\" de, ardından \"Rabbenâ lekel hamd\" ile devam et.", posture: .standing),
        TutorialStep(id: 6, title: "Sücud", instruction: "Secdeye kapan. Üç kez \"Sübhâne rabbiyel a'lâ\" de.", posture: .prostrate),
        TutorialStep(id: 7, title: "Celse", instruction: "İki secde arasında kısaca otur.", posture: .sitting),
        TutorialStep(id: 8, title: "İkinci Sücud", instruction: "Tekrar secdeye kapan. Üç kez \"Sübhâne rabbiyel a'lâ\" de.", posture: .prostrate),
    ]
}
