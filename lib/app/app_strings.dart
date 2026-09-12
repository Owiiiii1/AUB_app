class AppStrings {
  static const appName = 'AUB';
  static const academyMark = 'AUB Milano';
  static const academyName = 'Accademia Ucraina di Balletto';
  static const loginTitle = 'Accedi';
  static const emailLabel = 'Email';
  static const passwordLabel = 'Password';
  static const emailRequired = 'Inserisci un indirizzo email.';
  static const emailInvalid = 'Inserisci un indirizzo email valido.';
  static const passwordRequired = 'Inserisci la password.';
  static const invalidCredentials = 'Email o password non validi.';
  static const tooManyRequests = 'Troppi tentativi. Riprova più tardi.';
  static const noConnection = 'Connessione non disponibile.';
  static const timeout = 'La richiesta è scaduta. Riprova.';
  static const serverError = 'Si è verificato un errore. Riprova.';
  static const unauthenticated = 'Sessione scaduta. Accedi di nuovo.';
  static const unsupportedAccount = 'Questo account non è supportato nell\'app.';
  static const retry = 'Riprova';
  static const logout = 'Esci';
  static const logoutAccount = 'Esci dall\'account';
  static const logoutHint = 'Termina la sessione su questo dispositivo';
  static const logoutConfirmTitle = 'Confermi di voler uscire?';
  static const logoutConfirmBody =
      'Dovrai inserire nuovamente le credenziali per accedere all\'orario e al registro presenze.';
  static const logoutConfirmAction = 'Conferma ed Esci';
  static const restoringSession = 'Ripristino della sessione…';
  static const teacherArea = 'Area docente';
  static const teacherRole = 'Docente';
  static const teacherMark = 'Docenti';
  static const openAttendance = 'Apri presenze';
  static const nowLabel = 'Adesso';
  static const unmarked = 'Non segnato';
  static const draftUnsaved = 'Modifiche non salvate';
  static const noLessonsForAttendance =
      'Nessuna lezione da registrare in questa settimana.';
  static const noStudentsInLesson = 'Nessun allievo in questa lezione.';
  static const lessonsOfToday = 'Le lezioni di oggi';
  static const classLabel = 'Classe';
  static const yearLabel = 'Anno accademico';
  static const childrenLabel = 'Figli';
  static const noClass = 'Classe non assegnata';
  static const restoreOffline =
      'Connessione non disponibile. La sessione è ancora salvata.';
  static const homeTab = 'Home';
  static const childrenTab = 'Figli';
  static const calendarTab = 'Calendario';
  static const profileTab = 'Profilo';
  static const myProfile = 'Il mio profilo';
  static const schedule = 'Orario';
  static const mySchedule = 'Il mio orario';
  static const weeklySchedule = 'Orario settimanale';
  static const thisWeek = 'Questa settimana';
  static const noLesson = 'Nessuna lezione';
  static const noLessonToday = 'Nessuna lezione in programma oggi.';
  static const noUpcomingLesson = 'Nessuna lezione programmata';
  static const cancelled = 'Annullata';
  static const moved = 'Spostata';
  static const confirmed = 'Confermata';
  static const unpublishedWeek =
      'L\'orario di questa settimana non è ancora pubblicato.';
  static const noClassSchedule =
      'Nessuna classe assegnata. L\'orario non è disponibile.';
  static const noLessonsThisWeek = 'Nessuna lezione questa settimana';
  static const emptyDaySchedule = 'Nessuna lezione in programma';
  static const attendance = 'Presenze';
  static const attendanceRegister = 'Registro presenze';
  static const attendanceHistory = 'Storico lezioni';
  static const present = 'Presente';
  static const absent = 'Assente';
  static const excused = 'Giustificato';
  static const presentPlural = 'Presenti';
  static const absentPlural = 'Assenti';
  static const excusedPlural = 'Giustificati';
  static const totalLabel = 'Totale';
  static const totalLessons = 'Totale lezioni';
  static const sessionsLabel = 'sessioni';
  static const thisMonth = 'Questo mese';
  static const noAttendanceThisMonth =
      'Nessuna presenza registrata questo mese.';
  static const nextLesson = 'Prossima lezione';
  static const todayLessons = 'Lezioni di oggi';
  static const recentAttendance = 'Presenze recenti';
  static const fullSchedule = 'Orario completo';
  static const attendanceRegisterShort = 'Registro presenze';
  static const teacherLabel = 'Docente';
  static const spaceAndVenue = 'Spazio & Sede';
  static const allSchedule = 'Tutto l\'orario';
  static const today = 'Oggi';
  static const restDay = 'Riposo';
  static const markAllPresent = 'Segna tutti presenti';
  static const saveAttendance = 'Salva';
  static const attendanceSaved = 'Salvato';
  static const lessonCancelled = 'Lezione annullata';
  static const unsavedAttendance = 'Hai modifiche non salvate.\nUscire senza salvare?';
  static const cancel = 'Annulla';
  static const leaveWithoutSaving = 'Esci';
  static String scheduleOf(String name) => 'Orario di $name';
  static String attendanceOf(String name) => 'Presenze di $name';
  static String ciao(String name) => 'Ciao, $name';
  static String inMinutes(int minutes) => 'Oggi · Tra $minutes min';
  static String durationMin(int minutes) => '$minutes min';
  static String lessonsCount(int count) {
    if (count == 1) {
      return '1 lezione';
    }
    return '$count lezioni';
  }

  static const personalData = 'Dati personali';
  static const phoneLabel = 'Telefono';
  static const birthDateLabel = 'Data di nascita';
  static const addressLabel = 'Indirizzo';
  static const valueUnavailable = '—';
  static const securityAccess = 'Sicurezza e accesso';
  static const changePassword = 'Cambio password';
  static const changePasswordHint = 'Aggiorna la password di accesso';
  static const currentPasswordLabel = 'Password attuale';
  static const newPasswordLabel = 'Nuova password';
  static const confirmPasswordLabel = 'Conferma nuova password';
  static const savePassword = 'Salva password';
  static const passwordChanged = 'Password aggiornata.';
  static const currentPasswordWrong = 'La password attuale non è corretta.';
  static const passwordTooShort = 'La nuova password deve avere almeno 8 caratteri.';
  static const passwordMismatch = 'Le password non coincidono.';
  static const devices = 'Dispositivi';
  static const devicesHint = 'Sessioni attive su questo account';
  static const thisDevice = 'Questo dispositivo';
  static const revokeDevice = 'Revoca';
  static const revokeDeviceTitle = 'Revocare questo dispositivo?';
  static const revokeDeviceBody =
      'Dovrai accedere di nuovo su quel dispositivo.';
  static const logoutAllDevices = 'Esci da tutti i dispositivi';
  static const noOtherDevices = 'Nessun altro dispositivo connesso.';
  static const lastUsed = 'Ultimo utilizzo';
  static const preferencesLanguage = 'Preferenze e lingua';
  static const language = 'Lingua';
  static const languageHint = 'Lingua dell\'applicazione';
  static const languageItalian = 'Italiano';
  static const languageEnglish = 'English';
  static const languageRussian = 'Русский';
  static const languageLimited =
      'L\'app è attualmente disponibile in italiano.';
  static const pushNotifications = 'Notifiche push';
  static const pushHint = 'Avvisi su lezioni e presenze';
  static const pushUnavailable =
      'Le notifiche push saranno attive quando il servizio sarà disponibile.';

  static const yourChildren = 'I tuoi figli';
  static const upcomingCommitments = 'Prossimi impegni';
  static const parentRole = 'Genitore';
  static const changeStudent = 'Cambia allievo';
  static const nextLessonToday = 'Prossima lezione oggi';
  static const todayAtRest = 'Oggi a riposo';
  static const attendanceSummary = 'Riepilogo presenze';
  static const todaySchedule = 'Orario di oggi';
  static const recentRecords = 'Ultime presenze registrate';
  static const enrolledStudents = 'Allievi iscritti';
  static const seeFullSchedule = 'Vedi orario completo';
  static const seeFullAttendance = 'Vedi registro presenze';
  static const noChildren =
      'Nessun allievo associato a questo account.';
  static const seeAll = 'Vedi tutti';

  static String parentGreeting(String name, DateTime academyNow) {
    final hour = academyNow.hour;
    final hello = hour < 12
        ? 'Buongiorno'
        : hour < 18
            ? 'Buon pomeriggio'
            : 'Buonasera';
    return '$hello, $name';
  }

  static String viewingChild(String name) => 'Stai visualizzando: $name';

  static String enrolledCount(int count) {
    if (count == 1) {
      return 'Genitore · 1 allievo';
    }
    return 'Genitore · $count allievi';
  }

  static String pupilsCount(int count) {
    if (count == 1) {
      return '1 allievo';
    }
    return '$count allievi';
  }

  static String scheduleOfShort(String name) => 'Orario di $name';
}
