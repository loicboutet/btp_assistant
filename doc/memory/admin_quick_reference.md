# Admin UI - Quick Reference

## 🎨 Guide Rapide des Classes CSS

### Layout Components

```erb
<!-- Page Header -->
<div class="admin-page-header">
  <h1>Titre</h1>
  <p class="text-muted">Description</p>
</div>

<!-- Card Standard -->
<div class="admin-card">
  <div class="card-header">
    <h2>Titre de la carte</h2>
    <%= link_to "Action", path, class: "btn btn-sm btn-primary" %>
  </div>
  <!-- Contenu -->
</div>

<!-- Grid 2 Colonnes -->
<div class="admin-content-grid">
  <div class="admin-card">...</div>
  <div class="admin-card">...</div>
</div>
```

### Stats Cards

```erb
<div class="stats-grid">
  <div class="stat-card">
    <div class="stat-icon bg-green">
      <svg>...</svg>
    </div>
    <div class="stat-content">
      <div class="stat-value">247</div>
      <div class="stat-label">Label</div>
      <div class="stat-change positive">+12%</div>
    </div>
  </div>
</div>
```

**Icon Classes**: `bg-blue`, `bg-green`, `bg-purple`, `bg-orange`
**Change Classes**: `positive`, `negative`, `neutral`

### Tables

```erb
<table class="admin-table">
  <thead>
    <tr>
      <th>Colonne</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td data-label="Colonne">Valeur</td>
    </tr>
  </tbody>
</table>
```

**Row States**: `row-warning`, `row-danger`

### Buttons

```erb
<!-- Primary Button -->
<%= link_to path, class: "btn btn-primary" do %>
  <svg>...</svg>
  <span>Texte</span>
<% end %>

<!-- Outline Button -->
<%= link_to path, class: "btn btn-outline" do %>
  <span>Texte</span>
<% end %>

<!-- Danger Button -->
<%= link_to path, class: "btn btn-danger" do %>
  <span>Supprimer</span>
<% end %>
```

**Sizes**: `btn-xs`, `btn-sm`, `btn`, `btn-lg`
**Modifier**: `btn-with-icon`, `btn-block`

### Badges

```erb
<span class="badge badge-blue">Label</span>
<span class="status-badge status-success">Actif</span>
```

**Badge Colors**: `badge-blue`, `badge-red`, `badge-green`, `badge-purple`, `badge-orange`, `badge-yellow`
**Status Colors**: `status-success`, `status-warning`, `status-danger`, `status-info`

### Filters

```erb
<div class="admin-card">
  <h3 class="filters-title">Filtres</h3>
  <div class="filters-bar">
    <div class="search-box">
      <input type="search" class="form-input" placeholder="...">
    </div>
    <div class="filter-group">
      <select class="form-select">...</select>
    </div>
    <div class="filter-actions">
      <button class="btn btn-outline">Effacer</button>
      <button class="btn btn-primary">Filtrer</button>
    </div>
  </div>
</div>
```

### User Info

```erb
<div class="user-info">
  <div class="user-avatar">JD</div>
  <div>
    <div class="user-name">Jean Dupont</div>
    <div class="user-email">jean@example.com</div>
  </div>
</div>

<!-- Compact version -->
<div class="user-info-compact">
  <div class="user-avatar-sm">JD</div>
  <span>Jean Dupont</span>
</div>
```

### Activity Items

```erb
<div class="activity-list">
  <div class="activity-item">
    <div class="activity-icon bg-green">📄</div>
    <div class="activity-content">
      <div class="activity-title">Titre</div>
      <div class="activity-meta">Métadonnées</div>
    </div>
  </div>
</div>
```

### Alert Items

```erb
<div class="alert-list">
  <div class="alert-item warning">
    <div class="alert-icon">⚠️</div>
    <div class="alert-content">
      <div class="alert-title">Titre</div>
      <div class="alert-meta">Description</div>
    </div>
    <button class="btn btn-sm btn-primary">Action</button>
  </div>
</div>
```

**States**: `warning`, `danger`

### Details List

```erb
<div class="details-list">
  <div class="detail-item">
    <span class="detail-label">Label</span>
    <span class="detail-value">Valeur</span>
  </div>
</div>
```

### Alerts

```erb
<div class="alert alert-success">Message de succès</div>
<div class="alert alert-error">Message d'erreur</div>
<div class="alert alert-warning">Message d'avertissement</div>
<div class="alert alert-info">Message d'information</div>
```

### Pagination

```erb
<%= render 'shared/pagination', collection: @users %>
```

### Header with Actions

```erb
<div class="admin-page-header">
  <div class="header-with-actions">
    <div>
      <%= link_to "← Retour", path, class: "back-link" %>
      <h1>Titre</h1>
      <p class="text-muted">Description</p>
    </div>
    <div class="header-actions">
      <%= link_to "Action 1", path, class: "btn btn-primary" %>
      <%= link_to "Action 2", path, class: "btn btn-outline" %>
    </div>
  </div>
</div>
```

## 🎯 Utility Classes

### Text
- `text-muted` - Texte gris
- `text-nowrap` - Pas de retour à la ligne
- `text-center`, `text-left`, `text-right` - Alignement
- `font-weight-bold`, `font-weight-semibold` - Poids de police
- `small` - Petite taille
- `warning-text` - Texte orange
- `danger-text` - Texte rouge
- `success-text` - Texte vert

### Spacing
- `p-xs`, `p-sm`, `p-md`, `p-lg`, `p-xl` - Padding
- `m-xs`, `m-sm`, `m-md`, `m-lg`, `m-xl` - Margin

### Display
- `flex`, `flex-center`, `flex-between` - Flexbox
- `grid` - Grid
- `hidden` - Caché

## 📱 Responsive Breakpoints

- Mobile: < 768px
- Tablet: 769px - 1024px
- Desktop: > 1024px

## 🎨 Color Variables

```css
--primary-green: #1F9D55
--secondary-green: #25D366
--dark-green: #128C7E
--light-green: #DCF8C6
--accent-euro: #00A884

--bg-light: #F0F2F5
--bg-white: #FFFFFF

--text-dark: #1F2937
--text-gray: #6B7280
--text-light: #9CA3AF

--border-light: #E5E7EB
--border-gray: #D1D5DB
```

## 🔧 Stimulus Controller

Le layout admin utilise un contrôleur Stimulus pour la navigation mobile.

### Actions disponibles:
- `toggleSidebar()` - Toggle la sidebar sur mobile
- `closeSidebar()` - Ferme la sidebar (appelé après clic nav)
- `toggleProfileMenu()` - Toggle le menu profil
- `clickOutside()` - Ferme les menus en cliquant dehors

### Data attributes:
```html
<div data-controller="admin-layout">
  <button data-action="click->admin-layout#toggleSidebar">Menu</button>
  <aside data-admin-layout-target="sidebar">...</aside>
  <div data-admin-layout-target="profileMenu">...</div>
</div>
```

## ✅ Checklist pour Nouvelle Page

- [ ] Ajouter `content_for :title`
- [ ] Utiliser `.admin-page-header`
- [ ] Wrapper tables dans `.admin-card`
- [ ] Ajouter `data-label` sur `<td>` pour responsive
- [ ] Utiliser `.stats-grid` pour les stats
- [ ] Ajouter `.back-link` si page de détail
- [ ] Utiliser pagination si liste
- [ ] Tester sur mobile/tablet/desktop
- [ ] Vérifier les états hover
- [ ] Valider l'accessibilité

## 🚀 Tips & Best Practices

1. **Performance**: Utiliser `transform` au lieu de `top`/`left` pour animations
2. **Accessibilité**: Toujours ajouter `aria-label` sur boutons iconiques
3. **Responsive**: Penser mobile-first
4. **Consistance**: Utiliser les classes existantes avant d'en créer
5. **Semantic HTML**: Utiliser les bonnes balises (`<button>` vs `<a>`)
6. **SVG Icons**: Toujours définir width/height pour éviter les shifts
7. **Data Labels**: Requis sur `<td>` pour affichage mobile
8. **Button Groups**: Utiliser `.header-actions` ou `.action-buttons`
9. **Loading States**: Ajouter `.loading` pour spinners
10. **Empty States**: Utiliser `.empty-state` pour contenus vides

## 📚 Ressources

- Documentation complète: `doc/memory/admin_design_system.md`
- Style guide: `doc/style_guide.html`
- Variables CSS: `app/assets/stylesheets/style.css`
- CSS Admin: `app/assets/stylesheets/admin.css`
- Layout: `app/views/layouts/admin.html.erb`

## 🐛 Troubleshooting Common Issues

**Sidebar ne s'affiche pas**
- Vérifier `data-controller="admin-layout"`
- Vérifier import Stimulus controller

**Styles ne s'appliquent pas**
- Vérifier l'ordre des stylesheets dans le layout
- Faire `rails assets:precompile`
- Clear cache navigateur

**Table responsive cassée**
- Vérifier présence de `data-label` sur tous les `<td>`
- Vérifier wrapper `.admin-card`

**Buttons pas alignés**
- Utiliser `.btn-with-icon` pour icônes + texte
- Vérifier structure HTML (SVG + SPAN dans le lien)

## 📊 Tables avec Beaucoup de Colonnes

### Wrapper pour Scroll Horizontal

Pour les tables larges qui risquent de dépasser, utilisez le wrapper `.table-wrapper` :

```erb
<div class="admin-card">
  <div class="table-wrapper" data-controller="table-scroll">
    <table class="admin-table">
      <thead>
        <tr>
          <th>Colonne 1</th>
          <th>Colonne 2</th>
          <!-- ... beaucoup de colonnes ... -->
        </tr>
      </thead>
      <tbody>
        <tr>
          <td data-label="Colonne 1">Valeur 1</td>
          <td data-label="Colonne 2">Valeur 2</td>
          <!-- ... -->
        </tr>
      </tbody>
    </table>
  </div>
</div>
```

### Comportement Responsive

- **Desktop Large (> 1440px)** : Toutes les colonnes visibles, espacement confortable
- **Desktop Medium (769-1440px)** : Scroll horizontal avec min-width 1200px, éléments compacts
- **Mobile (< 768px)** : Mode carte avec data-labels

### Scroll Indicator

Un indicateur "→ Scroll →" apparaît automatiquement quand le contenu dépasse.
Il disparaît quand vous scrollez jusqu'à la fin.

### Optimisations Automatiques

Sur écrans moyens (769-1440px) :
- Taille de police réduite à 13px
- Padding réduit
- Avatars plus petits (36px)
- Badges compacts
- Boutons plus petits

