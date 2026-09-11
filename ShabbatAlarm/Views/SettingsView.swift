import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Section 1: Shabbat Setup Guide
                        VStack(alignment: .leading, spacing: 10) {
                            Text("הנחיות שימוש לשבת קודש")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                            
                            VStack(alignment: .leading, spacing: 14) {
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
                            .padding(14)
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(14)
                        }
                        .padding(.horizontal, 16)
                        
                        // Section 2: Halakhic aspects
                        VStack(alignment: .leading, spacing: 10) {
                            Text("מידע הלכתי")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("היבטים הלכתיים")
                                    .font(.headline)
                                
                                Text("השעון מכוון מראש מבעוד יום מערב שבת. השמעת הקול והפסקתו מתבצעים אוטומטית ע\"י מנגנון טיימר פנימי (גרמא ומעשה אוטומטי מראש). הרטט מבוטל כדי למנוע טלטול של המכשיר על גבי השידה.")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            .padding(14)
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(14)
                        }
                        .padding(.horizontal, 16)
                        
                        // Section 3: App info
                        VStack(alignment: .leading, spacing: 10) {
                            Text("אודות")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("גרסת אפליקציה")
                                    Spacer()
                                    Text("1.0.0 (iOS 17)")
                                        .foregroundColor(.secondary)
                                }
                                Divider()
                                HStack {
                                    Text("כיבוי אוטומטי")
                                    Spacer()
                                    Text("פעיל (ברירת מחדל: 2 דקות)")
                                        .foregroundColor(.green)
                                }
                                Divider()
                                HStack {
                                    Text("תמיכה בימי חול ושבת")
                                    Spacer()
                                    Text("מלאה")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(14)
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(14)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                    .padding(.top, 10)
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
