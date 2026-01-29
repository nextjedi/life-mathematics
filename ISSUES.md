# GitHub Issues

This document lists all issues to be created on GitHub for tracking development progress.

## Setup & Infrastructure

### Issue #1: Project Setup and Configuration
**Labels**: `setup`, `documentation`
**Priority**: High

**Description**:
Set up the Flutter project with proper structure and configuration.

**Tasks**:
- [ ] Initialize Flutter project
- [ ] Set up folder structure (models, screens, widgets, utils, services)
- [ ] Configure pubspec.yaml with dependencies
- [ ] Set up linting rules (analysis_options.yaml)
- [ ] Create .gitignore for Flutter
- [ ] Configure CI/CD pipeline (GitHub Actions)
- [ ] Set up code coverage reporting

**Acceptance Criteria**:
- Project builds successfully on Android, iOS, and Web
- All dependencies resolve correctly
- Linter runs without errors
- CI/CD pipeline passes

---

### Issue #2: Theme and Styling Setup
**Labels**: `ui`, `theme`, `enhancement`
**Priority**: High

**Description**:
Implement app-wide theming with support for light and dark modes.

**Tasks**:
- [ ] Define color schemes for light and dark themes
- [ ] Create Material Design 3 theme configuration
- [ ] Implement theme switcher
- [ ] Define text styles and typography
- [ ] Create custom button styles
- [ ] Define spacing and layout constants
- [ ] Test theme switching

**Acceptance Criteria**:
- Light and dark themes work correctly
- Theme persists after app restart
- All widgets respect theme colors
- Smooth theme transitions

---

## Core Calculators

### Issue #3: Basic Calculator - Core Logic
**Labels**: `feature`, `calculator`, `core`
**Priority**: High

**Description**:
Implement core calculation logic for the basic calculator.

**Tasks**:
- [ ] Create Calculator model/state class
- [ ] Implement basic operations (+, -, ×, ÷)
- [ ] Handle operator precedence
- [ ] Implement decimal number support
- [ ] Add percentage calculation
- [ ] Implement sign toggle
- [ ] Handle edge cases (division by zero, overflow)
- [ ] Write unit tests for all operations

**Acceptance Criteria**:
- All basic operations work correctly
- Decimal calculations are accurate
- Edge cases handled gracefully
- Unit tests pass with >90% coverage

---

### Issue #4: Basic Calculator - UI Implementation
**Labels**: `ui`, `calculator`, `feature`
**Priority**: High

**Description**:
Create the user interface for the basic calculator.

**Tasks**:
- [ ] Design calculator layout (number pad + display)
- [ ] Create reusable CalculatorButton widget
- [ ] Create DisplayScreen widget
- [ ] Implement button press animations
- [ ] Add haptic feedback
- [ ] Support portrait and landscape modes
- [ ] Make responsive for different screen sizes
- [ ] Write widget tests

**Acceptance Criteria**:
- Calculator UI looks clean and modern
- Buttons respond to touch with visual feedback
- Display shows input and results clearly
- Works on different screen sizes
- Landscape mode supported

---

### Issue #5: Memory Functions (MS, MR, M+, M-, MC)
**Labels**: `feature`, `calculator`, `enhancement`
**Priority**: Medium

**Description**:
Add memory functionality to the basic calculator.

**Tasks**:
- [ ] Implement memory storage
- [ ] Add MS (Memory Store) function
- [ ] Add MR (Memory Recall) function
- [ ] Add M+ (Memory Add) function
- [ ] Add M- (Memory Subtract) function
- [ ] Add MC (Memory Clear) function
- [ ] Add memory indicator on display
- [ ] Persist memory across sessions
- [ ] Write tests

**Acceptance Criteria**:
- All memory functions work correctly
- Memory persists after app restart
- Clear visual indicator when memory contains value
- Tests pass

---

### Issue #6: Compound Interest Calculator - Logic
**Labels**: `feature`, `financial`, `calculator`
**Priority**: High

**Description**:
Implement calculation logic for compound interest.

**Tasks**:
- [ ] Create CompoundInterest model
- [ ] Implement compound interest formula: A = P(1 + r/n)^(nt)
- [ ] Implement continuous compounding: A = Pe^(rt)
- [ ] Support different compounding frequencies
- [ ] Calculate total interest earned
- [ ] Calculate effective annual rate (EAR)
- [ ] Generate year-by-year breakdown
- [ ] Write unit tests
- [ ] Handle edge cases

**Acceptance Criteria**:
- Calculations are mathematically accurate
- All compounding frequencies supported
- Year-by-year breakdown correct
- Tests pass with >90% coverage

---

### Issue #7: Compound Interest Calculator - UI
**Labels**: `ui`, `financial`, `calculator`
**Priority**: High

**Description**:
Create user interface for compound interest calculator.

**Tasks**:
- [ ] Design input form (principal, rate, time, frequency)
- [ ] Create dropdown for compounding frequency
- [ ] Design results display card
- [ ] Create expandable breakdown table
- [ ] Add input validation with error messages
- [ ] Implement real-time calculation
- [ ] Add "Calculate" button
- [ ] Create comparison mode UI
- [ ] Make responsive
- [ ] Write widget tests

**Acceptance Criteria**:
- Form is intuitive and easy to use
- Input validation works correctly
- Results display clearly
- Breakdown table is readable
- Comparison mode functional

---

### Issue #8: Loan Calculator - Payment Calculator Logic
**Labels**: `feature`, `financial`, `calculator`
**Priority**: High

**Description**:
Implement loan payment calculation logic.

**Tasks**:
- [ ] Create Loan model
- [ ] Implement monthly payment formula: M = P[r(1+r)^n]/[(1+r)^n-1]
- [ ] Calculate total amount paid
- [ ] Calculate total interest
- [ ] Calculate payoff date
- [ ] Support different payment frequencies
- [ ] Write unit tests
- [ ] Handle edge cases (0% interest)

**Acceptance Criteria**:
- Payment calculations accurate
- All payment frequencies supported
- Edge cases handled
- Tests pass

---

### Issue #9: Loan Calculator - Amortization Schedule
**Labels**: `feature`, `financial`, `calculator`
**Priority**: Medium

**Description**:
Generate amortization schedule for loans.

**Tasks**:
- [ ] Create AmortizationSchedule model
- [ ] Generate monthly breakdown (payment #, amount, principal, interest, balance)
- [ ] Implement year-wise grouping
- [ ] Support extra payments
- [ ] Calculate impact of extra payments
- [ ] Write unit tests

**Acceptance Criteria**:
- Schedule calculations correct
- Extra payments handled properly
- Year grouping works
- Tests pass

---

### Issue #10: Loan Calculator - UI
**Labels**: `ui`, `financial`, `calculator`
**Priority**: High

**Description**:
Create UI for loan calculator with amortization schedule.

**Tasks**:
- [ ] Design loan input form
- [ ] Create results summary card
- [ ] Design amortization schedule table
- [ ] Add expandable/collapsible sections
- [ ] Create visual charts (principal vs interest pie chart)
- [ ] Add export button (placeholder for now)
- [ ] Implement "what-if" scenario inputs
- [ ] Make responsive
- [ ] Write widget tests

**Acceptance Criteria**:
- Form is user-friendly
- Results clearly displayed
- Schedule table is scrollable and readable
- Charts render correctly
- Responsive design

---

### Issue #11: EMI Calculator
**Labels**: `feature`, `financial`, `calculator`
**Priority**: Medium

**Description**:
Create EMI (Equated Monthly Installment) calculator.

**Tasks**:
- [ ] Create EMI model
- [ ] Implement EMI formula
- [ ] Create calculator logic with real-time updates
- [ ] Design UI with interactive sliders
- [ ] Add pie chart for principal/interest breakdown
- [ ] Create year-wise breakdown table
- [ ] Write tests

**Acceptance Criteria**:
- EMI calculations accurate
- Sliders update values in real-time
- Charts display correctly
- Tests pass

---

### Issue #12: Simple Interest Calculator
**Labels**: `feature`, `financial`, `calculator`
**Priority**: Medium

**Description**:
Implement simple interest calculator.

**Tasks**:
- [ ] Create SimpleInterest model
- [ ] Implement formula: SI = (P × r × t) / 100
- [ ] Support different time periods (years, months, days)
- [ ] Add comparison with compound interest
- [ ] Create UI
- [ ] Write tests

**Acceptance Criteria**:
- Calculations accurate
- Time period conversions correct
- Comparison feature works
- Tests pass

---

### Issue #13: Investment Return Calculator
**Labels**: `feature`, `financial`, `calculator`
**Priority**: Low

**Description**:
Create investment return calculator with ROI and CAGR.

**Tasks**:
- [ ] Create Investment model
- [ ] Implement ROI calculation
- [ ] Implement CAGR formula
- [ ] Support recurring investments (SIP)
- [ ] Calculate break-even point
- [ ] Create UI
- [ ] Write tests

**Acceptance Criteria**:
- All calculations accurate
- SIP support functional
- UI intuitive
- Tests pass

---

### Issue #14: Percentage Calculator Suite
**Labels**: `feature`, `calculator`
**Priority**: Low

**Description**:
Implement various percentage calculations.

**Tasks**:
- [ ] What is X% of Y?
- [ ] X is what % of Y?
- [ ] Percentage increase/decrease
- [ ] Percentage change
- [ ] Percentage difference
- [ ] Tip calculator
- [ ] Discount calculator
- [ ] Create unified UI with tabs/sections
- [ ] Write tests

**Acceptance Criteria**:
- All percentage operations work
- UI provides clear labels
- Tests pass

---

## Navigation & Core Features

### Issue #15: App Navigation Structure
**Labels**: `navigation`, `ui`, `core`
**Priority**: High

**Description**:
Implement main app navigation and routing.

**Tasks**:
- [ ] Choose navigation pattern (bottom nav, drawer, tabs)
- [ ] Create navigation routes
- [ ] Implement navigation bar/drawer
- [ ] Add calculator type selection
- [ ] Create home screen with calculator list
- [ ] Add smooth transitions
- [ ] Write navigation tests

**Acceptance Criteria**:
- Navigation is intuitive
- All screens accessible
- Transitions smooth
- Back button works correctly

---

### Issue #16: Calculation History Feature
**Labels**: `feature`, `history`, `storage`
**Priority**: Medium

**Description**:
Implement calculation history with storage and retrieval.

**Tasks**:
- [ ] Create History model
- [ ] Implement local storage (shared_preferences or Hive)
- [ ] Store recent calculations (last 50-100)
- [ ] Add timestamp to each calculation
- [ ] Categorize by calculator type
- [ ] Create History screen/panel
- [ ] Implement search functionality
- [ ] Add filter by calculator type
- [ ] Add clear history option
- [ ] Implement "reuse calculation" feature
- [ ] Write tests

**Acceptance Criteria**:
- History persists after app restart
- Calculations categorized correctly
- Search works efficiently
- Reuse feature functional
- Tests pass

---

### Issue #17: Settings Screen
**Labels**: `feature`, `settings`, `ui`
**Priority**: Medium

**Description**:
Create settings screen with user preferences.

**Tasks**:
- [ ] Create Settings screen UI
- [ ] Implement theme selection (light/dark/system)
- [ ] Add decimal precision setting (0-10)
- [ ] Add thousands separator options
- [ ] Add decimal separator options
- [ ] Add currency selection
- [ ] Add haptic feedback toggle
- [ ] Add sound effects toggle
- [ ] Add default calculator selection
- [ ] Persist settings in local storage
- [ ] Write tests

**Acceptance Criteria**:
- All settings work correctly
- Settings persist after restart
- UI is organized and clear
- Tests pass

---

### Issue #18: Number Formatting Service
**Labels**: `utility`, `service`, `enhancement`
**Priority**: Medium

**Description**:
Create service for formatting numbers according to user preferences.

**Tasks**:
- [ ] Create NumberFormatter service
- [ ] Implement decimal precision formatting
- [ ] Implement thousands separator
- [ ] Implement decimal separator
- [ ] Implement currency formatting
- [ ] Support different locales
- [ ] Write tests

**Acceptance Criteria**:
- Numbers format according to settings
- All separators work correctly
- Currency symbols display properly
- Tests pass

---

## UI/UX Enhancements

### Issue #19: Onboarding Flow
**Labels**: `ui`, `onboarding`, `enhancement`
**Priority**: Low

**Description**:
Create onboarding experience for first-time users.

**Tasks**:
- [ ] Design onboarding screens (3-5 screens)
- [ ] Highlight key features
- [ ] Add skip button
- [ ] Add "Get Started" button
- [ ] Show only on first launch
- [ ] Create smooth transitions
- [ ] Write tests

**Acceptance Criteria**:
- Onboarding shows on first launch only
- Can be skipped
- Clear and concise
- Smooth animations

---

### Issue #20: Animations and Transitions
**Labels**: `ui`, `animation`, `enhancement`
**Priority**: Low

**Description**:
Add smooth animations throughout the app.

**Tasks**:
- [ ] Button press animations
- [ ] Screen transition animations
- [ ] Number change animations in display
- [ ] Theme switch animation
- [ ] Loading animations
- [ ] Result reveal animations
- [ ] Ensure 60fps performance

**Acceptance Criteria**:
- Animations smooth and performant
- No jank or lag
- Enhance user experience

---

### Issue #21: Accessibility Improvements
**Labels**: `accessibility`, `a11y`, `enhancement`
**Priority**: Medium

**Description**:
Ensure app is accessible to all users.

**Tasks**:
- [ ] Add semantic labels to all widgets
- [ ] Test with screen readers
- [ ] Implement high contrast mode
- [ ] Support adjustable font sizes
- [ ] Add keyboard navigation
- [ ] Test with TalkBack (Android) and VoiceOver (iOS)
- [ ] Follow WCAG guidelines

**Acceptance Criteria**:
- Screen readers work correctly
- All interactive elements accessible
- Meets WCAG 2.1 AA standards

---

### Issue #22: Responsive Design for Tablets
**Labels**: `ui`, `responsive`, `enhancement`
**Priority**: Low

**Description**:
Optimize UI for tablet screens.

**Tasks**:
- [ ] Create tablet-specific layouts
- [ ] Use multi-column layouts where appropriate
- [ ] Test on various tablet sizes
- [ ] Optimize landscape mode
- [ ] Adjust font sizes and spacing

**Acceptance Criteria**:
- App looks great on tablets
- Utilizes screen space effectively
- All features work on tablets

---

## Testing & Quality

### Issue #23: Unit Tests for Calculation Logic
**Labels**: `testing`, `unit-test`
**Priority**: High

**Description**:
Write comprehensive unit tests for all calculation logic.

**Tasks**:
- [ ] Test basic calculator operations
- [ ] Test compound interest calculations
- [ ] Test loan calculations
- [ ] Test EMI calculations
- [ ] Test simple interest calculations
- [ ] Test edge cases
- [ ] Achieve >90% code coverage

**Acceptance Criteria**:
- All calculations tested
- Edge cases covered
- Coverage >90%
- All tests pass

---

### Issue #24: Widget Tests for UI Components
**Labels**: `testing`, `widget-test`
**Priority**: High

**Description**:
Write widget tests for all UI components.

**Tasks**:
- [ ] Test calculator button widgets
- [ ] Test display widgets
- [ ] Test input forms
- [ ] Test navigation
- [ ] Test theme switching
- [ ] Test settings screen
- [ ] Test history screen

**Acceptance Criteria**:
- All widgets tested
- User interactions tested
- All tests pass

---

### Issue #25: Integration Tests
**Labels**: `testing`, `integration-test`
**Priority**: Medium

**Description**:
Write integration tests for complete user flows.

**Tasks**:
- [ ] Test complete calculation flow
- [ ] Test navigation between calculators
- [ ] Test history save and recall
- [ ] Test settings persistence
- [ ] Test theme switching
- [ ] Run on emulators/simulators

**Acceptance Criteria**:
- End-to-end flows tested
- Tests run on CI/CD
- All tests pass

---

## Documentation

### Issue #26: Code Documentation
**Labels**: `documentation`
**Priority**: Low

**Description**:
Add comprehensive code documentation.

**Tasks**:
- [ ] Add dartdoc comments to all public APIs
- [ ] Document complex algorithms
- [ ] Add usage examples
- [ ] Generate API documentation
- [ ] Update README with API docs link

**Acceptance Criteria**:
- All public APIs documented
- Documentation clear and helpful
- Examples provided

---

### Issue #27: User Guide/Help Section
**Labels**: `documentation`, `feature`
**Priority**: Low

**Description**:
Create in-app help and user guide.

**Tasks**:
- [ ] Create Help screen
- [ ] Add calculator-specific help
- [ ] Include examples and tips
- [ ] Add FAQ section
- [ ] Link to online documentation

**Acceptance Criteria**:
- Help is accessible from all screens
- Content is clear and helpful
- Examples illustrate features

---

## Future Enhancements

### Issue #28: Export Functionality (PDF/CSV)
**Labels**: `feature`, `export`, `future`
**Priority**: Low

**Description**:
Allow users to export calculation results.

**Tasks**:
- [ ] Implement PDF export for amortization schedules
- [ ] Implement CSV export
- [ ] Add share functionality
- [ ] Test on all platforms

**Acceptance Criteria**:
- Export generates correct files
- Share works on all platforms
- Files are properly formatted

---

### Issue #29: Localization (i18n)
**Labels**: `feature`, `i18n`, `future`
**Priority**: Low

**Description**:
Add support for multiple languages.

**Tasks**:
- [ ] Set up Flutter intl
- [ ] Extract all strings
- [ ] Add support for 3-5 languages
- [ ] Test RTL languages
- [ ] Update documentation

**Acceptance Criteria**:
- App supports multiple languages
- RTL works correctly
- All strings translated

---

### Issue #30: Scientific Calculator
**Labels**: `feature`, `calculator`, `future`
**Priority**: Low

**Description**:
Add scientific calculator mode.

**Tasks**:
- [ ] Implement scientific functions (sin, cos, tan, log, etc.)
- [ ] Add parentheses support
- [ ] Implement advanced operations
- [ ] Create UI
- [ ] Write tests

**Acceptance Criteria**:
- All scientific functions work
- UI is intuitive
- Tests pass

---

## How to Use This Document

1. **Create Issues**: Copy each section into a new GitHub issue
2. **Add Labels**: Apply the specified labels
3. **Set Milestones**: Assign to Phase 1, 2, 3, or 4
4. **Prioritize**: Use priority labels (High, Medium, Low)
5. **Assign**: Assign issues to team members or contributors
6. **Track Progress**: Move issues through project board columns

## Issue Template

When creating issues, use this format:

```markdown
## Description
[Brief description of the issue]

## Tasks
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

## Acceptance Criteria
- Criterion 1
- Criterion 2
- Criterion 3

## Additional Context
[Any additional information, screenshots, or references]
```
