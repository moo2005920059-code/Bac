import { useState, useEffect, createContext, useContext } from "react";
import { db, auth } from "./firebase";
import {
  collection, getDocs, doc, updateDoc, deleteDoc,
  addDoc, query, orderBy, Timestamp, getDoc
} from "firebase/firestore";
import { signInWithEmailAndPassword, onAuthStateChanged, signOut } from "firebase/auth";

const AuthCtx = createContext(null);
const ADMIN_EMAILS = ["admin@flashcards.dz"];

export default function App() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState("dashboard");

  useEffect(() => {
    return onAuthStateChanged(auth, (u) => { setUser(u); setLoading(false); });
  }, []);

  if (loading) return <Loader />;
  if (!user || !ADMIN_EMAILS.includes(user.email)) return <LoginPage />;

  return (
    <AuthCtx.Provider value={{ user }}>
      <div className="min-h-screen bg-gray-950 text-white flex" dir="rtl">
        <Sidebar page={page} setPage={setPage} />
        <main className="flex-1 overflow-auto">
          {page === "dashboard" && <DashboardPage />}
          {page === "users"     && <UsersPage />}
          {page === "content"   && <ContentPage />}
          {page === "codes"     && <CodesPage />}
        </main>
      </div>
    </AuthCtx.Provider>
  );
}

function Loader() {
  return (
    <div className="min-h-screen bg-gray-950 flex items-center justify-center">
      <div className="w-10 h-10 border-4 border-violet-500 border-t-transparent rounded-full animate-spin" />
    </div>
  );
}

function LoginPage() {
  const [email, setEmail] = useState("");
  const [pass, setPass] = useState("");
  const [err, setErr] = useState("");
  const [loading, setLoading] = useState(false);

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true); setErr("");
    try {
      await signInWithEmailAndPassword(auth, email, pass);
    } catch {
      setErr("بريد أو كلمة مرور غير صحيحة");
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-950 flex items-center justify-center p-4" dir="rtl">
      <div className="bg-gray-900 border border-gray-800 rounded-2xl p-8 w-full max-w-md">
        <div className="text-center mb-8">
          <div className="text-5xl mb-3">⚡</div>
          <h1 className="text-2xl font-bold">لوحة التحكم</h1>
        </div>
        <form onSubmit={handleLogin} className="space-y-4">
          <input type="email" placeholder="البريد الإلكتروني" value={email}
            onChange={e => setEmail(e.target.value)}
            className="w-full bg-gray-800 border border-gray-700 rounded-xl px-4 py-3 text-white focus:outline-none focus:border-violet-500" />
          <input type="password" placeholder="كلمة المرور" value={pass}
            onChange={e => setPass(e.target.value)}
            className="w-full bg-gray-800 border border-gray-700 rounded-xl px-4 py-3 text-white focus:outline-none focus:border-violet-500" />
          {err && <p className="text-red-400 text-sm text-center">{err}</p>}
          <button type="submit" disabled={loading}
            className="w-full bg-violet-600 hover:bg-violet-700 text-white font-bold py-3 rounded-xl transition disabled:opacity-50">
            {loading ? "جاري الدخول..." : "دخول"}
          </button>
        </form>
      </div>
    </div>
  );
}

function Sidebar({ page, setPage }) {
  const links = [
    { id: "dashboard", icon: "📊", label: "الإحصائيات" },
    { id: "users",     icon: "👥", label: "المستخدمون" },
    { id: "content",   icon: "📚", label: "المحتوى" },
    { id: "codes",     icon: "🔑", label: "الأكواد" },
  ];
  return (
    <div className="w-60 bg-gray-900 border-l border-gray-800 flex flex-col min-h-screen">
      <div className="p-6 border-b border-gray-800">
        <div className="text-3xl mb-1">⚡</div>
        <div className="font-bold text-white">Flash Cards</div>
        <div className="text-gray-400 text-xs">لوحة التحكم</div>
      </div>
      <nav className="flex-1 p-4 space-y-1">
        {links.map(l => (
          <button key={l.id} onClick={() => setPage(l.id)}
            className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition
              ${page === l.id ? "bg-violet-600 text-white" : "text-gray-400 hover:bg-gray-800 hover:text-white"}`}>
            <span>{l.icon}</span>{l.label}
          </button>
        ))}
      </nav>
      <div className="p-4 border-t border-gray-800">
        <button onClick={() => signOut(auth)}
          className="w-full flex items-center gap-3 px-4 py-3 rounded-xl text-sm text-red-400 hover:bg-red-900/20 transition">
          🚪 تسجيل الخروج
        </button>
      </div>
    </div>
  );
}

// ─── Dashboard ────────────────────────────────────────────────────────────────
function DashboardPage() {
  const [stats, setStats] = useState({ users: 0, active: 0, codes: 0, usedCodes: 0 });

  useEffect(() => {
    const load = async () => {
      const usersSnap = await getDocs(collection(db, "users"));
      const codesSnap = await getDocs(collection(db, "codes"));
      const now = new Date();
      let active = 0;
      usersSnap.docs.forEach(d => {
        const data = d.data();
        if (data.expiryDate && data.expiryDate.toDate() > now) active++;
      });
      const usedCodes = codesSnap.docs.filter(d => d.data().isUsed).length;
      setStats({ users: usersSnap.size, active, codes: codesSnap.size, usedCodes });
    };
    load();
  }, []);

  const cards = [
    { label: "إجمالي المستخدمين", value: stats.users, icon: "👥", color: "from-violet-600 to-violet-800" },
    { label: "مشتركين فعالين", value: stats.active, icon: "✅", color: "from-green-600 to-green-800" },
    { label: "إجمالي الأكواد", value: stats.codes, icon: "🔑", color: "from-blue-600 to-blue-800" },
    { label: "أكواد مستخدمة", value: stats.usedCodes, icon: "✔️", color: "from-orange-600 to-orange-800" },
  ];

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-8">📊 الإحصائيات</h1>
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-6">
        {cards.map((c, i) => (
          <div key={i} className={`bg-gradient-to-br ${c.color} rounded-2xl p-6`}>
            <div className="text-3xl mb-3">{c.icon}</div>
            <div className="text-3xl font-bold">{c.value}</div>
            <div className="text-white/70 text-sm mt-1">{c.label}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── Users Page ───────────────────────────────────────────────────────────────
function UsersPage() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [editUser, setEditUser] = useState(null);

  useEffect(() => {
    getDocs(collection(db, "users")).then(snap => {
      setUsers(snap.docs.map(d => ({ id: d.id, ...d.data() })));
      setLoading(false);
    });
  }, []);

  const filtered = users.filter(u =>
    u.email?.includes(search) || u.fullName?.includes(search)
  );

  const toggleActive = async (userId, current) => {
    await updateDoc(doc(db, "users", userId), { isActive: !current });
    setUsers(u => u.map(x => x.id === userId ? { ...x, isActive: !current } : x));
  };

  const resetDevice = async (userId) => {
    await updateDoc(doc(db, "users", userId), { deviceId: "", deviceName: "" });
    alert("✅ تم إعادة تعيين الجهاز");
  };

  if (loading) return <Loader />;

  return (
    <div className="p-8">
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold">👥 المستخدمون ({users.length})</h1>
        <input value={search} onChange={e => setSearch(e.target.value)}
          placeholder="بحث..."
          className="bg-gray-800 border border-gray-700 rounded-xl px-4 py-2 text-white focus:outline-none focus:border-violet-500 w-64" />
      </div>

      <div className="space-y-3">
        {filtered.map(u => {
          const now = new Date();
          const expiry = u.expiryDate?.toDate?.();
          const isActive = expiry && expiry > now;
          return (
            <div key={u.id} className="bg-gray-900 border border-gray-800 rounded-2xl p-5">
              <div className="flex items-start justify-between gap-4">
                <div className="flex-1">
                  <div className="flex items-center gap-2 flex-wrap">
                    <span className="font-bold">{u.fullName || "—"}</span>
                    <span className={`text-xs px-2 py-0.5 rounded-full ${u.isActive ? "bg-green-900/50 text-green-400" : "bg-red-900/50 text-red-400"}`}>
                      {u.isActive ? "فعال" : "معطل"}
                    </span>
                    <span className={`text-xs px-2 py-0.5 rounded-full ${isActive ? "bg-violet-900/50 text-violet-400" : "bg-yellow-900/50 text-yellow-400"}`}>
                      {isActive ? "✅ مشترك" : "⏰ منتهي"}
                    </span>
                  </div>
                  <div className="text-gray-400 text-sm mt-1">{u.email}</div>
                  <div className="text-gray-500 text-xs mt-1">📱 {u.deviceName || "لا يوجد جهاز"}</div>
                  {expiry && <div className="text-gray-500 text-xs">📅 ينتهي: {expiry.toLocaleDateString("ar-SY")}</div>}
                  {u.activationCode && <div className="text-gray-500 text-xs">🔑 {u.activationCode}</div>}
                </div>
                <div className="flex flex-col gap-2">
                  <button onClick={() => toggleActive(u.id, u.isActive)}
                    className={`text-xs px-3 py-1.5 rounded-lg ${u.isActive ? "bg-red-900/30 text-red-400" : "bg-green-900/30 text-green-400"}`}>
                    {u.isActive ? "تعطيل" : "تفعيل"}
                  </button>
                  <button onClick={() => resetDevice(u.id)}
                    className="text-xs px-3 py-1.5 rounded-lg bg-yellow-900/30 text-yellow-400">
                    إعادة الجهاز
                  </button>
                  <button onClick={() => setEditUser(u)}
                    className="text-xs px-3 py-1.5 rounded-lg bg-violet-900/30 text-violet-400">
                    الاشتراك
                  </button>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {editUser && <SubscriptionModal user={editUser} onClose={() => setEditUser(null)}
        onSave={async (userId, start, end) => {
          await updateDoc(doc(db, "users", userId), {
            activatedAt: Timestamp.fromDate(new Date(start)),
            expiryDate: Timestamp.fromDate(new Date(end)),
          });
          setEditUser(null);
          alert("✅ تم تحديث الاشتراك");
        }} />}
    </div>
  );
}

function SubscriptionModal({ user, onClose, onSave }) {
  const [start, setStart] = useState(new Date().toISOString().split("T")[0]);
  const [end, setEnd] = useState("");

  const addMonths = (m) => {
    const d = new Date();
    d.setMonth(d.getMonth() + m);
    setStart(new Date().toISOString().split("T")[0]);
    setEnd(d.toISOString().split("T")[0]);
  };

  return (
    <div className="fixed inset-0 bg-black/60 flex items-center justify-center z-50 p-4">
      <div className="bg-gray-900 border border-gray-700 rounded-2xl p-6 w-full max-w-md">
        <h2 className="text-lg font-bold mb-1">تعديل الاشتراك</h2>
        <p className="text-gray-400 text-sm mb-5">{user.fullName}</p>
        <div className="flex gap-2 mb-4">
          {[1, 3, 6, 12].map(m => (
            <button key={m} onClick={() => addMonths(m)}
              className="flex-1 bg-violet-900/30 text-violet-400 text-xs py-2 rounded-lg">
              {m} شهر
            </button>
          ))}
        </div>
        <div className="space-y-3 mb-4">
          <div>
            <label className="text-gray-400 text-sm">البداية</label>
            <input type="date" value={start} onChange={e => setStart(e.target.value)}
              className="w-full bg-gray-800 border border-gray-700 rounded-xl px-4 py-2 text-white mt-1 focus:outline-none" />
          </div>
          <div>
            <label className="text-gray-400 text-sm">الانتهاء</label>
            <input type="date" value={end} onChange={e => setEnd(e.target.value)}
              className="w-full bg-gray-800 border border-gray-700 rounded-xl px-4 py-2 text-white mt-1 focus:outline-none" />
          </div>
        </div>
        <div className="flex gap-3">
          <button onClick={onClose} className="flex-1 bg-gray-800 text-gray-300 py-2.5 rounded-xl">إلغاء</button>
          <button onClick={() => onSave(user.id, start, end)}
            className="flex-1 bg-violet-600 text-white py-2.5 rounded-xl font-bold">حفظ</button>
        </div>
      </div>
    </div>
  );
}

// ─── Content Page ─────────────────────────────────────────────────────────────
function ContentPage() {
  const [sections, setSections] = useState([]);
  const [selectedSection, setSelectedSection] = useState(null);
  const [tab, setTab] = useState("subjects"); // subjects or sessions
  const [subjects, setSubjects] = useState([]);
  const [sessions, setSessions] = useState([]);
  const [selectedSubject, setSelectedSubject] = useState(null);
  const [lessons, setLessons] = useState([]);
  const [selectedLesson, setSelectedLesson] = useState(null);
  const [selectedSession, setSelectedSession] = useState(null);
  const [cards, setCards] = useState([]);
  const [showModal, setShowModal] = useState(null);

  useEffect(() => {
    getDocs(query(collection(db, "sections"), orderBy("order"))).then(snap => {
      setSections(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    });
  }, []);

  const loadSubjects = async (sectionId) => {
    const snap = await getDocs(query(collection(db, "sections", sectionId, "subjects"), orderBy("order")));
    setSubjects(snap.docs.map(d => ({ id: d.id, ...d.data() })));
  };

  const loadSessions = async (sectionId) => {
    const snap = await getDocs(query(collection(db, "sections", sectionId, "sessions"), orderBy("order")));
    setSessions(snap.docs.map(d => ({ id: d.id, ...d.data() })));
  };

  const loadLessons = async (sectionId, subjectId) => {
    const snap = await getDocs(query(collection(db, "sections", sectionId, "subjects", subjectId, "lessons"), orderBy("order")));
    setLessons(snap.docs.map(d => ({ id: d.id, ...d.data() })));
  };

  const loadSubjectCards = async (sectionId, subjectId, lessonId) => {
    const snap = await getDocs(query(collection(db, "sections", sectionId, "subjects", subjectId, "lessons", lessonId, "cards"), orderBy("order")));
    setCards(snap.docs.map(d => ({ id: d.id, ...d.data() })));
  };

  const loadSessionCards = async (sectionId, sessionId) => {
    const snap = await getDocs(query(collection(db, "sections", sectionId, "sessions", sessionId, "cards"), orderBy("order")));
    setCards(snap.docs.map(d => ({ id: d.id, ...d.data() })));
  };

  const addItem = async (data) => {
    if (showModal === "section") {
      await addDoc(collection(db, "sections"), { ...data, isActive: true, order: sections.length + 1 });
      const snap = await getDocs(query(collection(db, "sections"), orderBy("order")));
      setSections(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    } else if (showModal === "subject") {
      await addDoc(collection(db, "sections", selectedSection.id, "subjects"), { ...data, order: subjects.length + 1 });
      loadSubjects(selectedSection.id);
    } else if (showModal === "session") {
      await addDoc(collection(db, "sections", selectedSection.id, "sessions"), { ...data, order: sessions.length + 1, isFree: false, cardCount: 0 });
      loadSessions(selectedSection.id);
    } else if (showModal === "lesson") {
      await addDoc(collection(db, "sections", selectedSection.id, "subjects", selectedSubject.id, "lessons"), { ...data, order: lessons.length + 1, cardCount: 0 });
      loadLessons(selectedSection.id, selectedSubject.id);
    } else if (showModal === "card_subject") {
      await addDoc(collection(db, "sections", selectedSection.id, "subjects", selectedSubject.id, "lessons", selectedLesson.id, "cards"), { ...data, order: cards.length + 1 });
      loadSubjectCards(selectedSection.id, selectedSubject.id, selectedLesson.id);
    } else if (showModal === "card_session") {
      await addDoc(collection(db, "sections", selectedSection.id, "sessions", selectedSession.id, "cards"), { ...data, order: cards.length + 1 });
      loadSessionCards(selectedSection.id, selectedSession.id);
    }
    setShowModal(null);
  };

  return (
    <div className="p-8">
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold">📚 إدارة المحتوى</h1>
        <button onClick={() => setShowModal("section")}
          className="bg-violet-600 text-white px-4 py-2 rounded-xl text-sm font-bold">
          + إضافة قسم
        </button>
      </div>

      <div className="grid grid-cols-4 gap-4">
        {/* Sections */}
        <div>
          <h2 className="text-gray-400 text-xs mb-2">الأقسام</h2>
          {sections.map(s => (
            <button key={s.id} onClick={() => {
              setSelectedSection(s); setSelectedSubject(null); setSelectedLesson(null); setSelectedSession(null); setCards([]);
              loadSubjects(s.id); loadSessions(s.id);
            }}
              className={`w-full text-right p-3 rounded-xl mb-2 transition text-sm
                ${selectedSection?.id === s.id ? "bg-violet-600 text-white" : "bg-gray-900 text-gray-300 border border-gray-800"}`}>
              {s.name}
            </button>
          ))}
        </div>

        {/* Subjects or Sessions */}
        {selectedSection && (
          <div>
            <div className="flex gap-2 mb-2">
              <button onClick={() => setTab("subjects")}
                className={`text-xs px-3 py-1 rounded-lg ${tab === "subjects" ? "bg-violet-600 text-white" : "bg-gray-800 text-gray-400"}`}>
                المواد
              </button>
              <button onClick={() => setTab("sessions")}
                className={`text-xs px-3 py-1 rounded-lg ${tab === "sessions" ? "bg-violet-600 text-white" : "bg-gray-800 text-gray-400"}`}>
                الدورات
              </button>
              <button onClick={() => setShowModal(tab === "subjects" ? "subject" : "session")}
                className="text-xs text-violet-400 hover:text-violet-300">+</button>
            </div>

            {tab === "subjects" ? subjects.map(s => (
              <button key={s.id} onClick={() => { setSelectedSubject(s); setSelectedLesson(null); setCards([]); loadLessons(selectedSection.id, s.id); }}
                className={`w-full text-right p-3 rounded-xl mb-2 text-sm
                  ${selectedSubject?.id === s.id ? "bg-violet-600 text-white" : "bg-gray-900 text-gray-300 border border-gray-800"}`}>
                {s.icon} {s.name}
              </button>
            )) : sessions.map(s => (
              <button key={s.id} onClick={() => { setSelectedSession(s); setCards([]); loadSessionCards(selectedSection.id, s.id); }}
                className={`w-full text-right p-3 rounded-xl mb-2 text-sm
                  ${selectedSession?.id === s.id ? "bg-violet-600 text-white" : "bg-gray-900 text-gray-300 border border-gray-800"}`}>
                📅 {s.name}
              </button>
            ))}
          </div>
        )}

        {/* Lessons (for subjects) */}
        {selectedSubject && tab === "subjects" && (
          <div>
            <div className="flex items-center justify-between mb-2">
              <h2 className="text-gray-400 text-xs">الدروس</h2>
              <button onClick={() => setShowModal("lesson")} className="text-xs text-violet-400">+</button>
            </div>
            {lessons.map(l => (
              <button key={l.id} onClick={() => { setSelectedLesson(l); loadSubjectCards(selectedSection.id, selectedSubject.id, l.id); }}
                className={`w-full text-right p-3 rounded-xl mb-2 text-sm
                  ${selectedLesson?.id === l.id ? "bg-violet-600 text-white" : "bg-gray-900 text-gray-300 border border-gray-800"}`}>
                {l.name}
              </button>
            ))}
          </div>
        )}

        {/* Cards */}
        {(selectedLesson || selectedSession) && (
          <div>
            <div className="flex items-center justify-between mb-2">
              <h2 className="text-gray-400 text-xs">البطاقات ({cards.length})</h2>
              <button onClick={() => setShowModal(tab === "subjects" ? "card_subject" : "card_session")}
                className="text-xs text-violet-400">+</button>
            </div>
            <div className="space-y-2">
              {cards.map((c, i) => (
                <div key={c.id} className="bg-gray-900 border border-gray-800 rounded-xl p-3">
                  <div className="text-xs text-violet-400 mb-1">س{i + 1}</div>
                  <p className="text-white text-xs font-medium">{c.questionText || "📷 صورة"}</p>
                  <p className="text-gray-400 text-xs mt-1 border-t border-gray-800 pt-1">{c.answerText || "📷 صورة"}</p>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>

      {/* Modals */}
      {showModal === "section" && (
        <AddModal title="إضافة قسم" onClose={() => setShowModal(null)}
          fields={[
            { name: "name", label: "اسم القسم", placeholder: "بكالوريا علمي" },
            { name: "type", label: "النوع", placeholder: "sci_bac | lit_bac | ninth" },
          ]} onSubmit={addItem} />
      )}
      {showModal === "subject" && (
        <AddModal title="إضافة مادة" onClose={() => setShowModal(null)}
          fields={[
            { name: "name", label: "اسم المادة", placeholder: "فيزياء" },
            { name: "icon", label: "الأيقونة", placeholder: "⚛️" },
            { name: "colorIndex", label: "رقم اللون (0-7)", placeholder: "0", type: "number" },
          ]} onSubmit={addItem} />
      )}
      {showModal === "session" && (
        <AddModal title="إضافة دورة" onClose={() => setShowModal(null)}
          fields={[{ name: "name", label: "اسم الدورة", placeholder: "2024" }]}
          onSubmit={addItem} />
      )}
      {showModal === "lesson" && (
        <AddModal title="إضافة درس" onClose={() => setShowModal(null)}
          fields={[{ name: "name", label: "اسم الدرس", placeholder: "النواس الثقلي" }]}
          onSubmit={addItem} />
      )}
      {(showModal === "card_subject" || showModal === "card_session") && (
        <AddModal title="إضافة بطاقة" onClose={() => setShowModal(null)}
          fields={[
            { name: "questionText", label: "نص السؤال", placeholder: "اكتب السؤال...", multiline: true },
            { name: "questionImageUrl", label: "رابط صورة السؤال (اختياري)", placeholder: "https://..." },
            { name: "answerText", label: "نص الجواب", placeholder: "اكتب الجواب...", multiline: true },
            { name: "answerImageUrl", label: "رابط صورة الجواب (اختياري)", placeholder: "https://..." },
          ]} onSubmit={addItem} />
      )}
    </div>
  );
}

// ─── Codes Page ───────────────────────────────────────────────────────────────
function CodesPage() {
  const [codes, setCodes] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getDocs(collection(db, "codes")).then(snap => {
      setCodes(snap.docs.map(d => ({ id: d.id, ...d.data() })));
      setLoading(false);
    });
  }, []);

  const deleteCode = async (codeId) => {
    if (!window.confirm("حذف هذا الكود؟")) return;
    await deleteDoc(doc(db, "codes", codeId));
    setCodes(c => c.filter(x => x.id !== codeId));
  };

  if (loading) return <Loader />;

  const unused = codes.filter(c => !c.isUsed);
  const used = codes.filter(c => c.isUsed);

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-2">🔑 الأكواد</h1>
      <p className="text-gray-400 text-sm mb-6">استخدم بوت Telegram لتوليد أكواد جديدة</p>

      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="bg-green-900/20 border border-green-900/30 rounded-2xl p-4">
          <div className="text-2xl font-bold text-green-400">{unused.length}</div>
          <div className="text-green-400/70 text-sm">أكواد غير مستخدمة</div>
        </div>
        <div className="bg-gray-900 border border-gray-800 rounded-2xl p-4">
          <div className="text-2xl font-bold text-gray-400">{used.length}</div>
          <div className="text-gray-400/70 text-sm">أكواد مستخدمة</div>
        </div>
      </div>

      <h2 className="text-lg font-bold mb-3 text-green-400">الأكواد المتاحة</h2>
      <div className="space-y-2 mb-6">
        {unused.map(c => (
          <div key={c.id} className="bg-gray-900 border border-gray-800 rounded-xl p-4 flex items-center justify-between">
            <div>
              <code className="text-violet-400 font-bold">{c.code}</code>
              <div className="text-gray-500 text-xs mt-1">
                ينتهي: {c.expiryDate?.toDate?.().toLocaleDateString("ar-SY")}
              </div>
            </div>
            <button onClick={() => deleteCode(c.id)}
              className="text-red-400 text-xs hover:text-red-300">حذف</button>
          </div>
        ))}
        {unused.length === 0 && (
          <p className="text-gray-500 text-center py-4">لا توجد أكواد متاحة</p>
        )}
      </div>

      <h2 className="text-lg font-bold mb-3 text-gray-400">الأكواد المستخدمة</h2>
      <div className="space-y-2">
        {used.slice(0, 10).map(c => (
          <div key={c.id} className="bg-gray-900/50 border border-gray-800/50 rounded-xl p-4">
            <code className="text-gray-500 font-bold">{c.code}</code>
            <div className="text-gray-600 text-xs mt-1">
              استُخدم في: {c.usedAt?.toDate?.().toLocaleDateString("ar-SY")}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── Add Modal ────────────────────────────────────────────────────────────────
function AddModal({ title, fields, onClose, onSubmit }) {
  const [form, setForm] = useState({});

  return (
    <div className="fixed inset-0 bg-black/60 flex items-center justify-center z-50 p-4">
      <div className="bg-gray-900 border border-gray-700 rounded-2xl p-6 w-full max-w-md max-h-[90vh] overflow-y-auto">
        <h2 className="text-lg font-bold mb-5">{title}</h2>
        <div className="space-y-4">
          {fields.map(f => (
            <div key={f.name}>
              <label className="text-gray-400 text-sm block mb-1">{f.label}</label>
              {f.multiline ? (
                <textarea placeholder={f.placeholder}
                  onChange={e => setForm(p => ({ ...p, [f.name]: e.target.value }))}
                  rows={3}
                  className="w-full bg-gray-800 border border-gray-700 rounded-xl px-4 py-2.5 text-white placeholder-gray-500 focus:outline-none focus:border-violet-500 resize-none" />
              ) : (
                <input type={f.type || "text"} placeholder={f.placeholder}
                  onChange={e => setForm(p => ({ ...p, [f.name]: e.target.value }))}
                  className="w-full bg-gray-800 border border-gray-700 rounded-xl px-4 py-2.5 text-white placeholder-gray-500 focus:outline-none focus:border-violet-500" />
              )}
            </div>
          ))}
        </div>
        <div className="flex gap-3 mt-5">
          <button onClick={onClose} className="flex-1 bg-gray-800 text-gray-300 py-2.5 rounded-xl">إلغاء</button>
          <button onClick={() => onSubmit(form)}
            className="flex-1 bg-violet-600 text-white py-2.5 rounded-xl font-bold">إضافة</button>
        </div>
      </div>
    </div>
  );
}
