/**
 *   GRANITE DATA SERVICES
 *   Copyright (C) 2006-2015 GRANITE DATA SERVICES S.A.S.
 *
 *   This file is part of the Granite Data Services Platform.
 *
 *   Granite Data Services is free software; you can redistribute it and/or
 *   modify it under the terms of the GNU Lesser General Public
 *   License as published by the Free Software Foundation; either
 *   version 2.1 of the License, or (at your option) any later version.
 *
 *   Granite Data Services is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser
 *   General Public License for more details.
 *
 *   You should have received a copy of the GNU Lesser General Public
 *   License along with this library; if not, write to the Free Software
 *   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301,
 *   USA, or see <http://www.gnu.org/licenses/>.
 */
package org.granite.client.javafx.util;

import java.util.ArrayList;
import java.util.List;

import org.granite.client.javafx.util.ChangeWatcher.Trigger;

import javafx.beans.InvalidationListener;
import javafx.beans.Observable;
import javafx.beans.property.Property;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;


public class ChainedProperty<T, P> implements Property<P>, ChangeListener<T>, Trigger<T, P> {
	
	private final PropertyGetter<T, P> targetPropertyGetter;
	
	private Property<P> targetProperty = null;
	
	private List<ChangeListener<? super P>> changeListeners = new ArrayList<ChangeListener<? super P>>();
	private List<InvalidationListener> invalidationListeners = new ArrayList<InvalidationListener>();
	
	
	public static <T, P> ChainedProperty<T, P> chain(ObservableValue<T> sourceObservableValue, PropertyGetter<T, P> targetPropertyGetter) {
		return new ChainedProperty<T, P>(sourceObservableValue, targetPropertyGetter);
	}

	public static <T, P> ChainedProperty<T, P> chain(ChangeWatcher<T> sourceWatcher, PropertyGetter<T, P> targetPropertyGetter) {
		return new ChainedProperty<T, P>(sourceWatcher, targetPropertyGetter);
	}
	
	
	public ChainedProperty(ObservableValue<T> sourceObservableValue, PropertyGetter<T, P> targetPropertyGetter) {
		this.targetPropertyGetter = targetPropertyGetter;
		
		sourceObservableValue.addListener(this);
		
		afterChange(sourceObservableValue.getValue(), null);
	}
	
	public ChainedProperty(ChangeWatcher<T> sourceWatcher, PropertyGetter<T, P> targetPropertyGetter) {
		this.targetPropertyGetter = targetPropertyGetter;
		
		sourceWatcher.addTrigger(this);
	}
	
	public <X> ChainedProperty<P, X> chain(PropertyGetter<P, X> nextPropertyGetter) {
		return new ChainedProperty<P, X>(this, nextPropertyGetter);
	}
	
	public P beforeChange(T oldSource) {
		P oldValue = targetProperty != null ? targetProperty.getValue() : null;
		
		if (targetProperty != null) {
			targetProperty.removeListener(targetChangeListener);
			targetProperty.removeListener(targetInvalidationListener);
		}
		
		return oldValue;
	}
	
	public void afterChange(T newSource, P oldValue) {
		targetProperty = newSource != null ? targetPropertyGetter.getProperty(newSource) : null;
		
		P newValue = targetProperty != null ? targetProperty.getValue() : null;
		
		if (targetProperty != null) {
			targetProperty.addListener(targetChangeListener);
			targetProperty.addListener(targetInvalidationListener);
			
			if (newValue != oldValue) {
				targetInvalidationListener.invalidated(ChainedProperty.this);
				targetChangeListener.changed(ChainedProperty.this, oldValue, newValue);
			}
		}
	}
	
	@Override
	public void changed(ObservableValue<? extends T> source, T oldSource, T newSource) {
		P oldValue = beforeChange(oldSource);
		
		afterChange(newSource, oldValue);
	}
	
	private ChangeListener<? super P> targetChangeListener = new ChangeListener<P>() {
		@Override
		public void changed(ObservableValue<? extends P> target, P oldTarget, P newTarget) {
			for (ChangeListener<? super P> listener : changeListeners) {
				listener.changed(target, oldTarget, newTarget);
			}
		}
	};
	
	private InvalidationListener targetInvalidationListener = new InvalidationListener() {
		@Override
		public void invalidated(Observable observable) {
			for (InvalidationListener listener : invalidationListeners)
				listener.invalidated(observable);
		}			
	};
	
	@Override
	public Object getBean() {
		if (targetProperty == null)
			return null;
		return targetProperty.getBean();
	}

	@Override
	public String getName() {
		if (targetProperty == null)
			return null;
		return targetProperty.getName();
	}

	@Override
	public P getValue() {
		if (targetProperty == null)
			return null;
		return targetProperty.getValue();
	}
	
	@Override
	public void setValue(P value) {
		if (targetProperty == null)
			return;
		targetProperty.setValue(value);
	}
	
	@Override
	public void addListener(ChangeListener<? super P> listener) {
		changeListeners.add(listener);
	}
	
	@Override
	public void removeListener(ChangeListener<? super P> listener) {
		changeListeners.remove(listener);
	}
	
	@Override
	public void addListener(InvalidationListener listener) {
		invalidationListeners.add(listener);
	}
	
	@Override
	public void removeListener(InvalidationListener listener) {
		invalidationListeners.remove(listener);
	}
	
	@Override
	public void bind(ObservableValue<? extends P> observableValue) {
		throw new UnsupportedOperationException();
	}

	@Override
	public void bindBidirectional(Property<P> property) {
		throw new UnsupportedOperationException();
	}
	
	@Override
	public boolean isBound() {
		throw new UnsupportedOperationException();
	}
	
	@Override
	public void unbind() {
		throw new UnsupportedOperationException();
	}

	@Override
	public void unbindBidirectional(Property<P> property) {
		throw new UnsupportedOperationException();
	}
	
	
	public static interface PropertyGetter<B, T> {
		
		Property<T> getProperty(B bean);
	}
}	
