"""
بوت Telegram لتوليد أكواد التفعيل
متطلبات:
pip install python-telegram-bot firebase-admin
"""

import os
import random
import string
from datetime import datetime, timedelta
import firebase_admin
from firebase_admin import credentials, firestore
from telegram import Update
from telegram.ext import Application, CommandHandler, ContextTypes

# ─── إعداد Firebase ───────────────────────────────────────────────────────────
# حمّل serviceAccountKey.json من Firebase Console → Project Settings → Service accounts
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# ─── إعدادات البوت ────────────────────────────────────────────────────────────
BOT_TOKEN = "YOUR_BOT_TOKEN"  # من @BotFather
ADMIN_IDS = [123456789]  # ضع Telegram ID بتاعك هنا

# ─── توليد كود عشوائي ─────────────────────────────────────────────────────────
def generate_code():
    chars = string.ascii_uppercase + string.digits
    random_part = ''.join(random.choices(chars, k=8))
    year = datetime.now().year
    return f"BAC-{year}-{random_part}"

# ─── التحقق من الصلاحيات ─────────────────────────────────────────────────────
def is_admin(user_id: int) -> bool:
    return user_id in ADMIN_IDS

# ─── /start ───────────────────────────────────────────────────────────────────
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text(
        "👋 أهلاً بك في بوت Flash Cards\n\n"
        "الأوامر المتاحة:\n"
        "/gencode [أشهر] - توليد كود تفعيل\n"
        "/codes - عرض الأكواد غير المستخدمة\n"
        "/stats - إحصائيات المستخدمين\n\n"
        "مثال: /gencode 3 (كود لمدة 3 أشهر)"
    )

# ─── /gencode ─────────────────────────────────────────────────────────────────
async def gen_code(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_admin(update.effective_user.id):
        await update.message.reply_text("❌ غير مصرح لك")
        return

    # مدة الاشتراك بالأشهر (افتراضي 12 شهر)
    months = 12
    if context.args:
        try:
            months = int(context.args[0])
        except ValueError:
            await update.message.reply_text("❌ أدخل رقم صحيح للأشهر")
            return

    code = generate_code()
    expiry = datetime.now() + timedelta(days=30 * months)

    # حفظ الكود في Firebase
    db.collection('codes').add({
        'code': code,
        'isUsed': False,
        'usedBy': None,
        'expiryDate': expiry,
        'createdAt': firestore.SERVER_TIMESTAMP,
        'months': months,
        'createdBy': update.effective_user.id,
    })

    await update.message.reply_text(
        f"✅ تم توليد الكود:\n\n"
        f"🔑 `{code}`\n\n"
        f"⏱ المدة: {months} شهر\n"
        f"📅 ينتهي في: {expiry.strftime('%Y-%m-%d')}",
        parse_mode='Markdown'
    )

# ─── /gencodes (توليد عدة أكواد) ─────────────────────────────────────────────
async def gen_codes(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_admin(update.effective_user.id):
        await update.message.reply_text("❌ غير مصرح لك")
        return

    count = 5
    months = 12

    if len(context.args) >= 1:
        try: count = int(context.args[0])
        except: pass
    if len(context.args) >= 2:
        try: months = int(context.args[1])
        except: pass

    expiry = datetime.now() + timedelta(days=30 * months)
    codes_list = []

    batch = db.batch()
    for _ in range(min(count, 20)):  # حد أقصى 20 كود
        code = generate_code()
        codes_list.append(code)
        ref = db.collection('codes').document()
        batch.set(ref, {
            'code': code,
            'isUsed': False,
            'usedBy': None,
            'expiryDate': expiry,
            'createdAt': firestore.SERVER_TIMESTAMP,
            'months': months,
        })
    batch.commit()

    codes_text = '\n'.join([f"`{c}`" for c in codes_list])
    await update.message.reply_text(
        f"✅ تم توليد {len(codes_list)} كود:\n\n{codes_text}\n\n"
        f"📅 تنتهي في: {expiry.strftime('%Y-%m-%d')}",
        parse_mode='Markdown'
    )

# ─── /codes ───────────────────────────────────────────────────────────────────
async def list_codes(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_admin(update.effective_user.id):
        await update.message.reply_text("❌ غير مصرح لك")
        return

    snap = db.collection('codes').where('isUsed', '==', False).limit(20).get()

    if not snap:
        await update.message.reply_text("لا توجد أكواد غير مستخدمة")
        return

    codes_text = ""
    for doc in snap:
        data = doc.to_dict()
        expiry = data['expiryDate'].strftime('%Y-%m-%d') if data.get('expiryDate') else 'غير محدد'
        codes_text += f"🔑 `{data['code']}` - ينتهي {expiry}\n"

    await update.message.reply_text(
        f"📋 الأكواد غير المستخدمة ({len(snap)}):\n\n{codes_text}",
        parse_mode='Markdown'
    )

# ─── /stats ───────────────────────────────────────────────────────────────────
async def stats(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_admin(update.effective_user.id):
        await update.message.reply_text("❌ غير مصرح لك")
        return

    users = db.collection('users').get()
    codes = db.collection('codes').get()

    total_users = len(users)
    active_users = sum(1 for u in users
                      if u.to_dict().get('expiryDate') and
                      u.to_dict()['expiryDate'] > datetime.now())
    total_codes = len(codes)
    used_codes = sum(1 for c in codes if c.to_dict().get('isUsed'))

    await update.message.reply_text(
        f"📊 إحصائيات Flash Cards:\n\n"
        f"👥 إجمالي المستخدمين: {total_users}\n"
        f"✅ مشتركين فعالين: {active_users}\n"
        f"🔑 إجمالي الأكواد: {total_codes}\n"
        f"✔️ أكواد مستخدمة: {used_codes}\n"
        f"⏳ أكواد متبقية: {total_codes - used_codes}"
    )

# ─── /deletecode ──────────────────────────────────────────────────────────────
async def delete_code(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_admin(update.effective_user.id):
        await update.message.reply_text("❌ غير مصرح لك")
        return

    if not context.args:
        await update.message.reply_text("استخدم: /deletecode BAC-2025-XXXXXXXX")
        return

    code = context.args[0].upper()
    snap = db.collection('codes').where('code', '==', code).get()

    if not snap:
        await update.message.reply_text("❌ الكود غير موجود")
        return

    for doc in snap:
        doc.reference.delete()

    await update.message.reply_text(f"✅ تم حذف الكود: `{code}`", parse_mode='Markdown')

# ─── تشغيل البوت ─────────────────────────────────────────────────────────────
def main():
    app = Application.builder().token(BOT_TOKEN).build()

    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("gencode", gen_code))
    app.add_handler(CommandHandler("gencodes", gen_codes))
    app.add_handler(CommandHandler("codes", list_codes))
    app.add_handler(CommandHandler("stats", stats))
    app.add_handler(CommandHandler("deletecode", delete_code))

    print("✅ البوت يعمل...")
    app.run_polling()

if __name__ == '__main__':
    main()
