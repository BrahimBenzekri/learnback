# Skill-Swap Learning Platform – Complete Backend Blueprint

## 1. Overview
The Skill-Swap Learning Platform is a peer-to-peer skill exchange system where users can teach skills they possess and learn new ones from others. The platform facilitates matching users with complementary skill sets, provides structured learning roadmaps, tracks progress through proof submissions, and rewards successful completion with points that unlock professional courses.

## 2. Core Features
- **User Registration & Authentication** – Sign up, log in, manage profile.
- **Skill Management** – Users can list skills they own (self-reported or verified) and skills they want to learn.
- **Skill Verification Tests** – Optional quizzes to validate proficiency in a skill.
- **Smart Matching** – Algorithm that pairs User A (has Skill X, wants Skill Y) with User B (has Skill Y, wants Skill X).
- **Roadmap Generation** – Upon match approval, a step-by-step learning/teaching plan is created (initially mock/AI-generated).
- **Progress Tracking** – Users submit proof (text, image, etc.) for each roadmap step; partners approve.
- **Final Quiz** – After completing the roadmap, both users take a quiz to confirm learning.
- **Points & Rewards** – Successful matches award points; points can be used to unlock professional courses.
- **Professional Courses** – Premium content posted by the school/admin, accessible with points.
- **Course Unlock & Tracking** – Users can unlock, enroll, and complete courses.

## 3. User Journey
1. **Registration** – User signs up with name, email, password.
2. **Profile Setup** – User adds skills they already have (self-reported) and skills they want to learn.
3. **Skill Verification (Optional)** – For any owned skill, user can take a verification test to prove proficiency; passing adds the skill as "verified".
4. **Matching** – System searches for complementary users. When a match is found, both users receive a proposal.
5. **Match Approval** – Both users review the proposed swap (teach Skill A to User B, teach Skill B to User A) and must approve.
6. **Roadmap Generation** – A learning roadmap with steps and deadlines is generated (AI or mock) and presented to both users.
7. **Roadmap Approval** – Both users must approve the roadmap to activate the match.
8. **Progress Submission** – Users submit proof for each step (e.g., screenshot, text answer). Partner reviews and marks as complete.
9. **Final Quiz** – After all steps are done, both users take a final quiz on what they learned.
10. **Completion & Points** – If both pass the quiz, the match is marked completed, and both earn points.
11. **Unlock Professional Courses** – Users can spend points to unlock professional courses posted by the school.
12. **Course Learning** – Users can access course content and track completion.

## 4. Technology Stack

### Backend
- **Runtime**: Node.js
- **Framework**: Express.js
- **Language**: JavaScript (ES6+)
- **Authentication**: JSON Web Tokens (JWT)
- **Password Hashing**: bcrypt
- **File Uploads**: Multer
- **Environment Variables**: dotenv
- **Validation**: Joi (recommended)
- **Real-time (future)**: Socket.io for notifications

### Database
- **Database**: MongoDB (NoSQL)
- **ODM**: Mongoose (for schema modeling and validation)
- **Hosting Options**: Local (for development) or MongoDB Atlas (for production)

### Development Tools
- **Version Control**: Git
- **Package Manager**: npm
- **API Testing**: Postman or Insomnia
- **Environment**: Node.js with nodemon for auto-restart

## 5. Database Schema (Mongoose Models)

Below are the Mongoose schemas for each collection, including fields, data types, and relationships.

### 5.1 User Model – `User`
| Field        | Type     | Description |
|--------------|----------|-------------|
| _id          | ObjectId | Primary key |
| name         | String   | Required |
| email        | String   | Unique, required, lowercase |
| passwordHash | String   | Required, minlength 6 |
| profile      | Object   | { avatar, bio, location } |
| points       | Number   | Default 0 |
| role         | String   | 'user', 'admin', 'school' (default 'user') |
| createdAt    | Date     | Default now |

### 5.2 Skill Model – `Skill`
| Field       | Type     | Description |
|-------------|----------|-------------|
| _id         | ObjectId | Primary key |
| name        | String   | Unique, required |
| description | String   | Optional |
| category    | String   | Optional grouping |

### 5.3 Skill Test Model – `SkillTest`
| Field        | Type     | Description |
|--------------|----------|-------------|
| _id          | ObjectId | Primary key |
| skillId      | ObjectId | Ref `Skill`, required |
| level        | String   | Beginner/Intermediate/Advanced |
| questions    | Array    | [{ question, options, correctAnswer }] |
| passingScore | Number   | Required (1-100) |
| createdAt    | Date     | Default now |

### 5.4 Professional Course Model – `ProfessionalCourse`
| Field         | Type     | Description |
|---------------|----------|-------------|
| _id           | ObjectId | Primary key |
| title         | String   | Required |
| description   | String   | Required |
| requiredPoints| Number   | Required, min 0 |
| content       | String   | URL or rich text |
| postedBy      | ObjectId | Ref `User` (school/admin) |
| createdAt     | Date     | Default now |
| difficulty    | String   | Beginner/Intermediate/Advanced |

### 5.5 Final Quiz Model – `FinalQuiz`
| Field        | Type     | Description |
|--------------|----------|-------------|
| _id          | ObjectId | Primary key |
| matchId      | ObjectId | Ref `Match`, unique |
| questions    | Array    | [{ question, options, correctAnswer }] |
| passingScore | Number   | Default 70 |
| createdAt    | Date     | Default now |

### 5.6 User Skill Model – `UserSkill`
| Field    | Type     | Description |
|----------|----------|-------------|
| _id      | ObjectId | Primary key |
| userId   | ObjectId | Ref `User`, required |
| skillId  | ObjectId | Ref `Skill`, required |
| level    | String   | Beginner/Intermediate/Advanced |
| addedAt  | Date     | Default now |
| source   | String   | self-reported/verified/match-completion |
> *Unique index on (userId, skillId)*

### 5.7 Learning Goal Model – `LearningGoal`
| Field     | Type     | Description |
|-----------|----------|-------------|
| _id       | ObjectId | Primary key |
| userId    | ObjectId | Ref `User`, required |
| skillId   | ObjectId | Ref `Skill`, required |
| createdAt | Date     | Default now |
> *Unique index on (userId, skillId)*

### 5.8 User Skill Verification Model – `UserSkillVerification`
| Field      | Type     | Description |
|------------|----------|-------------|
| _id        | ObjectId | Primary key |
| userId     | ObjectId | Ref `User`, required |
| skillId    | ObjectId | Ref `Skill`, required |
| testId     | ObjectId | Ref `SkillTest`, required |
| score      | Number   | Required |
| passed     | Boolean  | Required |
| verifiedAt | Date     | Default now |
> *Index on (userId, skillId, verifiedAt)*

### 5.9 Match Model – `Match`
| Field              | Type     | Description |
|--------------------|----------|-------------|
| _id                | ObjectId | Primary key |
| userAId            | ObjectId | Ref `User`, required |
| userBId            | ObjectId | Ref `User`, required |
| teachSkillAId      | ObjectId | Ref `Skill`, required |
| teachSkillBId      | ObjectId | Ref `Skill`, required |
| status             | String   | pending/active/completed/cancelled |
| roadmapApprovedByA | Boolean  | Default false |
| roadmapApprovedByB | Boolean  | Default false |
| createdAt          | Date     | Default now |
| activatedAt        | Date     | Optional |
| completedAt        | Date     | Optional |

### 5.10 Roadmap Step Model – `RoadmapStep`
| Field       | Type     | Description |
|-------------|----------|-------------|
| _id         | ObjectId | Primary key |
| matchId     | ObjectId | Ref `Match`, required |
| stepNumber  | Number   | Required |
| description | String   | Required |
| deadline    | Date     | Optional |
> *Unique index on (matchId, stepNumber)*

### 5.11 Step Progress Model – `StepProgress`
| Field         | Type     | Description |
|---------------|----------|-------------|
| _id           | ObjectId | Primary key |
| matchId       | ObjectId | Ref `Match`, required |
| stepId        | ObjectId | Ref `RoadmapStep`, required |
| userId        | ObjectId | Ref `User`, required |
| proofType     | String   | text/image/link |
| proofValue    | String   | Required |
| submittedAt   | Date     | Default now |
| status        | String   | pending/approved/rejected |
| reviewedBy    | ObjectId | Ref `User` |
| reviewComment | String   | Optional |
| reviewedAt    | Date     | Optional |

### 5.12 Quiz Result Model – `QuizResult`
| Field    | Type     | Description |
|----------|----------|-------------|
| _id      | ObjectId | Primary key |
| matchId  | ObjectId | Ref `Match`, required |
| userId   | ObjectId | Ref `User`, required |
| score    | Number   | Required |
| passed   | Boolean  | Required |
| takenAt  | Date     | Default now |
> *Unique index on (matchId, userId)*

### 5.13 User Course Unlock Model – `UserCourseUnlock`
| Field       | Type     | Description |
|-------------|----------|-------------|
| _id         | ObjectId | Primary key |
| userId      | ObjectId | Ref `User`, required |
| courseId    | ObjectId | Ref `ProfessionalCourse`, required |
| status      | String   | unlocked/enrolled/completed |
| unlockedAt  | Date     | Default now |
| enrolledAt  | Date     | Optional |
| completedAt | Date     | Optional |
> *Unique index on (userId, courseId)*

## 6. Backend Architecture

### Folder Structure
skill-swap-backend/
├── server.js # Entry point
├── package.json # Dependencies
├── .env # Environment variables
├── .gitignore # Git ignore
├── config/
│ └── database.js # MongoDB connection
├── models/ # 13 Mongoose models (files as above)
├── controllers/ # Business logic
│ ├── authController.js # Register, login
│ ├── userController.js # Profile, points
│ ├── skillController.js # List skills, add user skills/goals
│ ├── testController.js # Take skill tests, get results
│ ├── matchController.js # Create match, approve, list matches
│ ├── roadmapController.js # Generate, approve, get roadmap
│ ├── progressController.js # Submit proof, approve/reject
│ ├── quizController.js # Take final quiz, get results
│ └── courseController.js # List courses, unlock, enroll
├── routes/ # API route definitions
│ ├── authRoutes.js
│ ├── userRoutes.js
│ ├── skillRoutes.js
│ ├── testRoutes.js
│ ├── matchRoutes.js
│ ├── roadmapRoutes.js
│ ├── progressRoutes.js
│ ├── quizRoutes.js
│ └── courseRoutes.js
├── middleware/ # Custom middleware
│ ├── auth.js # JWT verification
│ └── errorHandler.js # Central error handling
├── utils/ # Helper functions
│ ├── aiRoadmapGenerator.js # (Placeholder) AI integration
│ └── validators.js # Input validation schemas
└── uploads/ # For file uploads (proof images)


### Key Components
- **Models**: Define database structure and relationships using Mongoose.
- **Controllers**: Contain business logic for each resource; interact with models.
- **Routes**: Map HTTP endpoints to controller functions.
- **Middleware**: Process requests before they reach controllers (authentication, error handling).
- **Utils**: Reusable helper functions (validation, AI roadmap generation).

## 7. API Design & Structure

### Base URL
All endpoints are prefixed with `/api`.  
Example: `https://api.skillswap.com/api/v1/...` (versioning can be added later).

### Authentication
- Most endpoints require a valid JWT token.
- Token must be sent in the `Authorization` header as `Bearer <token>`.
- Protected routes use the `auth` middleware to verify the token and attach `req.user`.

### Response Format
All responses follow a consistent JSON structure:

**Success:**
8. API Endpoints (Detailed)
Resource	Method	Endpoint	Description	Request Body	Auth
Auth	POST	/api/auth/register	Register new user	{ name, email, password }	No
Auth	POST	/api/auth/login	Login, return token	{ email, password }	No
Users	GET	/api/users/profile	Get current user profile	–	Yes
Users	PUT	/api/users/profile	Update profile	{ name, profile }	Yes
Users	GET	/api/users/points	Get user's total points	–	Yes
Skills	GET	/api/skills	List all skills	–	Yes
Skills	POST	/api/skills	(Admin) Create a new skill	{ name, description }	Yes (admin)
User Skills	POST	/api/users/skills	Add skill to user's owned skills	{ skillId, level }	Yes
User Skills	GET	/api/users/skills	Get user's owned skills	–	Yes
Learning Goals	POST	/api/users/goals	Add learning goal	{ skillId }	Yes
Learning Goals	GET	/api/users/goals	Get user's learning goals	–	Yes
Skill Tests	GET	/api/tests/:skillId	Get test for a skill	–	Yes
Skill Tests	POST	/api/tests/:testId/take	Submit test answers	{ answers: [] }	Yes
Skill Verifications	GET	/api/verifications	List user's test results	–	Yes
Matches	POST	/api/matches	Create a match (initiate with another user)	{ targetUserId, teachSkillId, learnSkillId }	Yes
Matches	GET	/api/matches	List user's matches (filter by status)	–	Yes
Matches	GET	/api/matches/:id	Get match details	–	Yes
Matches	PUT	/api/matches/:id/approve-proposal	Approve match proposal	–	Yes
Matches	GET	/api/matches/potential	Get potential matches for current user	–	Yes
Roadmap	GET	/api/matches/:id/roadmap	Get roadmap steps	–	Yes
Roadmap	POST	/api/matches/:id/generate-roadmap	Generate steps (AI/mock)	–	Yes
Roadmap	PUT	/api/matches/:id/approve-roadmap	Approve roadmap (user)	–	Yes
Progress	POST	/api/steps/:stepId/progress	Submit proof for step	{ proofType, proofValue } (multipart/form-data if file)	Yes
Progress	PUT	/api/progress/:id/review	Approve/reject proof	{ status, comment }	Yes
Progress	GET	/api/matches/:id/progress	Get all progress for match	–	Yes
Final Quiz	GET	/api/matches/:id/quiz	Get final quiz	–	Yes
Final Quiz	POST	/api/matches/:id/quiz/submit	Submit quiz answers	{ answers: [] }	Yes
Final Quiz	GET	/api/matches/:id/quiz-results	Get quiz results for match	–	Yes
Courses	GET	/api/courses	List professional courses	–	Yes
Courses	GET	/api/courses/:id	Get single course details	–	Yes
Courses	POST	/api/courses/:id/unlock	Unlock course with points	–	Yes
Courses	POST	/api/courses/:id/enroll	Enroll in unlocked course	–	Yes
Courses	PUT	/api/courses/:id/complete	Mark course as completed	–	Yes
Courses (Admin)	POST		/api/courses	Create a new course	{ title, description, requiredPoints, content, difficulty }	Yes (admin)