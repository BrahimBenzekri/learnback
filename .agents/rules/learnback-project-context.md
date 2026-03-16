---
trigger: always_on
---

# LearnBack – Project Context for AI Assistant

## 🧠 What Is This App?
LearnBack is a **peer-to-peer skill exchange mobile app** built with Flutter + Riverpod.
Users teach skills they know and learn skills they want — matched with complementary partners.
Think of it as a "skill barter system" with structured learning, proof submission, quizzes, and rewards.

---

## 👤 User Roles
| Role | Description |
|---|---|
| `user` | Default role — can match, learn, teach, earn points |
| `admin` | Can create skills and professional courses |
| `school` | Posts professional courses accessible via points |

---

## 🗺️ Full User Journey (Build in This Order)

1. **Register** — name, email, password → JWT returned
2. **Profile Setup** — add owned skills (self-reported) + skills to learn (goals)
3. **Skill Verification (Optional)** — take a quiz for an owned skill → if passed, skill marked as `verified`
4. **Matching** — system finds users with complementary skills → both get a proposal
5. **Match Approval** — both users approve the swap proposal
6. **Roadmap Generation** — AI/mock generates step-by-step learning plan with deadlines
7. **Roadmap Approval** — both users approve the roadmap → match becomes `active`
8. **Progress Submission** — users submit proof (text/image/link) per step → partner approves
9. **Final Quiz** — after all steps done, both take a quiz on what they learned
10. **Completion & Points** — both pass quiz → match = `completed` → both earn points
11. **Unlock Professional Courses** — spend points to unlock premium courses
12. **Course Learning** — access content, track: `unlocked → enrolled → completed`

---

## 🏗️ Flutter App Feature Modules

Map each backend resource to a Flutter feature folder:

```
features/
├── auth/           → Register, Login, JWT storage
├── profile/        → View/edit profile, points display
├── skills/         → Browse all skills, add owned skills, add learning goals
├── verification/   → Take skill verification quiz, view results
├── matches/        → Browse potential matches, view match list, approve proposals
├── roadmap/        → View roadmap steps, approve roadmap
├── progress/       → Submit proof per step, review partner's proof
├── quiz/           → Take final quiz, view results
└── courses/        → Browse courses, unlock, enroll, complete
```

---

## 🔑 Authentication
- **JWT-based** — token stored in `flutter_secure_storage`
- Token injected via Dio interceptor on every request
- Header format: `Authorization: Bearer <token>`
- On 401 response → clear token → redirect to login
- Auth state managed by `authProvider` (keepAlive: true)

---

## 🌐 API Base URL
```
Base: /api
All endpoints require Bearer token EXCEPT: POST /api/auth/register, POST /api/auth/login
```

---

## 📡 Full API Endpoints Reference

### 🔐 Auth
| Method | Endpoint | Body | Auth |
|---|---|---|---|
| POST | `/api/auth/register` | `{ name, email, password }` | No |
| POST | `/api/auth/login` | `{ email, password }` | No |

### 👤 Users
| Method | Endpoint | Body | Auth |
|---|---|---|---|
| GET | `/api/users/profile` | — | Yes |
| PUT | `/api/users/profile` | `{ name, profile }` | Yes |
| GET | `/api/users/points` | — | Yes |

### 🎯 Skills
| Method | Endpoint | Body | Auth |
|---|---|---|---|
| GET | `/api/skills` | — | Yes |
| POST | `/api/skills` | `{ name, description }` | Yes (admin) |
| POST | `/api/users/skills` | `{ skillId, level }` | Yes |
| GET | `/api/users/skills` | — | Yes |
| POST | `/api/users/goals` | `{ skillId }` | Yes |
| GET | `/api/users/goals` | — | Yes |

### 🧪 Skill Tests & Verifications
| Method | Endpoint | Body | Auth |
|---|---|---|---|
| GET | `/api/tests/:skillId` | — | Yes |
| POST | `/api/tests/:testId/take` | `{ answers: [] }` | Yes |
| GET | `/api/verifications` | — | Yes |

### 🤝 Matches
| Method | Endpoint | Body | Auth |
|---|---|---|---|
| POST | `/api/matches` | `{ targetUserId, teachSkillId, learnSkillId }` | Yes |
| GET | `/api/matches` | — | Yes |
| GET | `/api/matches/:id` | — | Yes |
| PUT | `/api/matches/:id/approve-proposal` | — | Yes |
| GET | `/api/matches/potential` | — | Yes |

### 🗺️ Roadmap
| Method | Endpoint | Body | Auth |
|---|---|---|---|
| GET | `/api/matches/:id/roadmap` | — | Yes |
| POST | `/api/matches/:id/generate-roadmap` | — | Yes |
| PUT | `/api/matches/:id/approve-roadmap` | — | Yes |

### 📸 Progress
| Method | Endpoint | Body | Auth |
|---|---|---|---|
| POST | `/api/steps/:stepId/progress` | `{ proofType, proofValue }` multipart/form-data | Yes |
| PUT | `/api/progress/:id/review` | `{ status, comment }` | Yes |
| GET | `/api/matches/:id/progress` | — | Yes |

### 📝 Final Quiz
| Method | Endpoint | Body | Auth |
|---|---|---|---|
| GET | `/api/matches/:id/quiz` | — | Yes |
| POST | `/api/matches/:id/quiz/submit` | `{ answers: [] }` | Yes |
| GET | `/api/matches/:id/quiz-results` | — | Yes |

### 📚 Courses
| Method | Endpoint | Body | Auth |
|---|---|---|---|
| GET | `/api/courses` | — | Yes |
| GET | `/api/courses/:id` | — | Yes |
| POST | `/api/courses/:id/unlock` | — | Yes |
| POST | `/api/courses/:id/enroll` | — | Yes |
| PUT | `/api/courses/:id/complete` | — | Yes |
| POST | `/api/courses` | `{ title, description, requiredPoints, content, difficulty }` | Yes (admin) |

---

## 🗄️ Key Data Models (Dart/Freezed)

### User
```dart
String id, name, email;
int points;
String role; // 'user' | 'admin' | 'school'
String? avatar, bio, location;
```

### Skill
```dart
String id, name;
String? description, category;
```

### UserSkill
```dart
String id, userId, skillId;
String level;   // 'Beginner' | 'Intermediate' | 'Advanced'
String source;  // 'self-reported' | 'verified' | 'match-completion'
```

### LearningGoal
```dart
String id, userId, skillId;
DateTime createdAt;
```

### Match
```dart
String id, userAId, userBId;
String teachSkillAId, teachSkillBId;
String status; // 'pending' | 'active' | 'completed' | 'cancelled'
bool roadmapApprovedByA, roadmapApprovedByB;
DateTime? activatedAt, completedAt;
```

### RoadmapStep
```dart
String id, matchId, description;
int stepNumber;
DateTime? deadline;
```

### StepProgress
```dart
String id, matchId, stepId, userId;
String proofType;  // 'text' | 'image' | 'link'
String proofValue;
String status;     // 'pending' | 'approved' | 'rejected'
String? reviewedBy, reviewComment;
```

### ProfessionalCourse
```dart
String id, title, description, postedBy;
int requiredPoints;
String? content;
String difficulty; // 'Beginner' | 'Intermediate' | 'Advanced'
```

### UserCourseUnlock
```dart
String id, userId, courseId;
String status; // 'unlocked' | 'enrolled' | 'completed'
DateTime unlockedAt;
DateTime? enrolledAt, completedAt;
```

### QuizResult
```dart
String id, matchId, userId;
int score;
bool passed;
DateTime takenAt;
```

---

## 🖥️ Key Screens to Build

| Screen | Feature | Notes |
|---|---|---|
| SplashScreen | auth | Check token, redirect |
| LoginScreen | auth | Email + password |
| RegisterScreen | auth | Name, email, password |
| HomeScreen | dashboard | Points, active matches summary |
| ProfileScreen | profile | Avatar, bio, location, points |
| SkillsListScreen | skills | Browse all skills |
| MySkillsScreen | skills | Owned skills + add new |
| MyGoalsScreen | skills | Learning goals + add new |
| VerificationQuizScreen | verification | MCQ quiz for a skill |
| PotentialMatchesScreen | matches | List of suggested matches |
| MatchesListScreen | matches | All user matches by status |
| MatchDetailScreen | matches | Full match info + approve |
| RoadmapScreen | roadmap | Steps list + approve roadmap |
| StepProgressScreen | progress | Submit proof + review partner |
| FinalQuizScreen | quiz | MCQ final quiz |
| QuizResultScreen | quiz | Score + pass/fail |
| CoursesListScreen | courses | Browse professional courses |
| CourseDetailScreen | courses | Unlock / enroll / complete |

---

## ⚡ Business Logic Rules (Critical for AI to Know)

- A match requires **BOTH users to approve** the proposal before becoming active.
- A roadmap requires **BOTH users to approve** before progress submission starts.
- Progress proof is submitted by one user and **reviewed/approved by the partner**.
- The final quiz is only available **after all roadmap steps are approved**.
- Points are awarded **only if both users pass** the final quiz.
- A course can only be unlocked if the user has **enough points** (`user.points >= course.requiredPoints`).
- Course flow is strictly: `unlocked → enrolled → completed` — no skipping.
- Skill source must be updated to `match-completion` after a successful match.
- Skill verification tests have a `passingScore` — only update skill to `verified` if passed.
- Match status flow: `pending → active → completed | cancelled`

---

## 📁 Proof Upload Notes
- Proof can be: `text` (string), `image` (file upload), or `link` (URL string)
- Image uploads use `multipart/form-data` via Dio `FormData`
- Use `image_picker` to pick image, compress before sending
- Show upload progress indicator during submission

---

## 🎨 App Tone & UX Notes
- App name: **LearnBack**
- Audience: Students / young professionals
- Vibe: Clean, modern, motivating — think Duolingo meets LinkedIn
- Key colors: to be defined in `AppColors` — suggest using a primary accent + neutral palette
- Always show: loading skeletons, empty states with encouragement, error states with retry