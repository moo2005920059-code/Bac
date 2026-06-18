/*
هيكل قاعدة البيانات الجديد:

sections/{sectionId}
  name: "بكالوريا علمي"
  type: "sci_bac" | "lit_bac" | "ninth"
  order: 1
  isActive: true

  subjects/{subjectId}
    name: "فيزياء"
    icon: "⚛️"
    colorIndex: 1
    order: 1
    isFree: false

    lessons/{lessonId}
      name: "النواس الثقلي"
      order: 1
      cardCount: 0

      cards/{cardId}
        questionText: "نص السؤال"
        questionImageUrl: "" 
        answerText: "نص الجواب"
        answerImageUrl: ""
        order: 1

  sessions/{sessionId}
    name: "2024"
    order: 1
    isFree: false

    cards/{cardId}
      questionText: "نص السؤال"
      questionImageUrl: ""
      answerText: "نص الجواب"
      answerImageUrl: ""
      order: 1

codes/{codeId}
  code: "BAC-2025-XXXX"
  isUsed: false
  usedBy: null
  expiryDate: timestamp
  createdAt: timestamp
  sectionId: "sci_bac" (اختياري - لقسم معين)

users/{userId}
  email: ""
  fullName: ""
  phone: ""
  isActive: true
  deviceId: ""
  deviceName: ""
  activationCode: ""
  activatedAt: timestamp
  expiryDate: timestamp
  sectionId: "" (القسم المفعّل)
  savedCards: []
  createdAt: timestamp
*/
