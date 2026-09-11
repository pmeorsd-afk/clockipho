import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                // Section 1: Shabbat Setup Guide
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        GuideStepRow(
                            number: "1",
                            title: "חיבור למטען",
                            description: "מומלץ לחבר את האייפון למטען על השידה לפני כניסת השבת."
                        )
                        
                        Divider()
                        
                        GuideStepRow(
                            number: "2",
                            title: "הפעלת מצב שבת באפליקציה",
                            description: "לחץ על כפתור 'מצב שבת' הסגול לפני השינה. המסך יהפוך לשחור מוחלט עם שעון עמום ולא יינעל."
                        )
                        
                        Divider()
                        
                        GuideStepRow(
                            number: "3",
                            title: "מצב 'נא לא להפריע' (Focus)",
                            description: "הפעל מצב נא לא להפריע כדי ששיחות נכנסות או הודעות לא יפריעו בשבת."
                        )
                        
                        Divider()
                        
                        GuideStepRow(
                            number: "4",
                            title: "אפס מגע במהלך השבת",
                            description: "השעון יצלצל בזמן המדויק, יפעל במשך הזמן שהגדרת (לדוגמה 2 דקות), ויכבה מעצמו לחלוטין ללא שום צורך לגעת במכשיר."
                        )
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("הנחיות שימוש לשבת קודש")
                }
                
                // Section 2: Halakhic aspects
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("היבטים הלכתיים")
                            .font(.headline)
                        
                        Text("השעון מכוון מראש מבעוד יום מערב שבת. השמעת הקול והפסקתו מתבצעים אוטומטית ע\"י מנגנון טיימר פנימי (גרמא ומעשה אוטומטי מראש). הרטט מבוטל כדי למנוע טלטול של המכשיר על גבי השידה.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("מידע הלכתי")
                }
                
                // Section 3: App info
                Section {
                    HStack {
                        Text("גרסת אפליקציה")
                        Spacer()
                        Text("1.0.0 (iOS 17)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("כיבוי אוטומטי")
                        Spacer()
                        Text("פעיל (ברירת מחדל: 2 דקות)")
                            .foregroundColor(.green)
                    }
                    HStack {
                        Text("תמיכה בימי חול ושבת")
                        Spacer()
                        Text("מלאה")
                            .foregroundColor(.blue)
                    }
                } header: {
                    Text("אודות")
                }
            }
            .navigationTitle("הנחיות והגדרות")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("סגור") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct GuideStepRow: View {
    let number: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.headline)
                .fontWeight(.bold)
                .frame(width: 28, height: 28)
                .background(Color.purple.opacity(0.15))
                .foregroundColor(.purple)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
