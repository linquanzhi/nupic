/* ---------------------------------------------------------------------
 * Numenta Platform for Intelligent Computing (NuPIC)
 * Copyright (C) 2013, Numenta, Inc.  Unless you have an agreement
 * with Numenta, Inc., for a separate license for this software code, the
 * following terms and conditions apply:
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see http://www.gnu.org/licenses.
 *
 * http://numenta.org/licenses/
 * ---------------------------------------------------------------------
 */

%module(package="nupic.bindings") math
%include <bindings/py/Exception.i>

///////////////////////////////////////////////////////////////////
/// Includes necessary to compile the C wrappers
///////////////////////////////////////////////////////////////////

%pythoncode %{
# ----------------------------------------------------------------------
# Numenta Platform for Intelligent Computing (NuPIC)
# Copyright (C) 2013, Numenta, Inc.  Unless you have an agreement
# with Numenta, Inc., for a separate license for this software code, the
# following terms and conditions apply:
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses.
#
# http://numenta.org/licenses/
# ----------------------------------------------------------------------

_MATH = _math

%}

%{
/* ---------------------------------------------------------------------
 * Numenta Platform for Intelligent Computing (NuPIC)
 * Copyright (C) 2013, Numenta, Inc.  Unless you have an agreement
 * with Numenta, Inc., for a separate license for this software code, the
 * following terms and conditions apply:
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see http://www.gnu.org/licenses.
 *
 * http://numenta.org/licenses/
 * ---------------------------------------------------------------------
 */

#include <cmath>
#include <nta/types/Types.hpp>
#include <nta/math/Utils.hpp>
#include <nta/math/Math.hpp>
#include <nta/math/Functions.hpp>
#include <nta/math/ArrayAlgo.hpp>
#include <nta/utils/Random.hpp>
#include <numpy/arrayobject.h>
%}

%naturalvar;

%{
#define SWIG_FILE_WITH_INIT
%}

%include <bindings/py/Numpy.i> // %import does not work.

%init %{

// Perform necessary library initialization (in C++).
import_array();
  
%}

%include <bindings/py/Types.i>
%include <bindings/py/Reals.i>

///////////////////////////////////////////////////////////////////
/// Utility functions that are expensive in Python but fast in C.
///////////////////////////////////////////////////////////////////


%include <bindings/py/math/SparseMatrix.i>
%include <bindings/py/math/SparseTensor.i>

//--------------------------------------------------------------------------------
%inline {

  inline nta::Real64 lgamma(nta::Real64 x)
  {
    return nta::lgamma(x);
  }

  inline nta::Real64 digamma(nta::Real64 x)
  {
    return nta::digamma(x);
  }

  inline nta::Real64 beta(nta::Real64 x, nta::Real64 y)
  {
    return nta::beta(x, y);
  }

  inline nta::Real64 erf(nta::Real64 x)
  {
    return nta::erf(x);
  }

  bool nearlyZeroRange(PyObject* py_x, nta::Real32 eps =nta::Epsilon)
  {
    nta::NumpyVectorT<nta::Real32> x(py_x);
    return nta::nearlyZeroRange(x.begin(), x.end(), eps);
  }

  bool nearlyEqualRange(PyObject* py_x, PyObject* py_y, nta::Real32 eps =nta::Epsilon)
  {
    nta::NumpyVectorT<nta::Real32> x(py_x), y(py_y);
    return nta::nearlyEqualRange(x.begin(), x.end(), y.begin(), y.end(), eps);
  }

  bool positive_less_than(PyObject* py_x, nta::Real32 eps =nta::Epsilon)
  {
    nta::NumpyVectorT<nta::Real32> x(py_x);
    return nta::positive_less_than(x.begin(), x.end(), eps);
  }

  /*
  inline PyObject* quantize_255(PyObject* py_x, nta::Real32 x_min, nta::Real32 x_max)
  {
    nta::NumpyVectorT<nta::Real32> x(py_x), y(x.size());
    nta::quantize(x.begin(), x.end(), y.begin(), y.end(),
		  x_min, x_max, 1, 255);
    return y.forPython();
  }

  inline PyObject* quantize_65535(PyObject* py_x, nta::Real32 x_min, nta::Real32 x_max)
  {
    nta::NumpyVectorT<nta::Real32> x(py_x), y(x.size());
    nta::quantize(x.begin(), x.end(), y.begin(), y.end(),
		  x_min, x_max, 1, 65535);
    return y.forPython();
  }
  */			 

  PyObject* winnerTakesAll_3(size_t k, size_t seg_size, PyObject* py_x)
  {
    nta::NumpyVectorT<nta::Real32> x(py_x);
    std::vector<int> ind;
    std::vector<nta::Real32> nz;
    nta::winnerTakesAll3(k, seg_size, x.begin(), x.end(),
		    std::back_inserter(ind), std::back_inserter(nz));
    PyObject *toReturn = PyTuple_New(2);
    PyTuple_SET_ITEM(toReturn, 0, nta::PyInt32Vector(ind.begin(), ind.end()));
    PyTuple_SET_ITEM(toReturn, 1, nta::PyFloatVector(nz.begin(), nz.end()));
    return toReturn;
  }
}

//--------------------------------------------------------------------------------

%include <nta/math/Functions.hpp>

// ----- Random -----

%include <nta/utils/LoggingException.hpp>
%include <nta/utils/Random.hpp>

%extend nta::Random {

// For unpickling.
%pythoncode %{
def __setstate__(self, state):
  self.this = _MATH.new_Random(1)
  self.thisown = 1
  self.setState(state)
%}

// For pickling (should be compatible with setState()).
std::string __getstate__()
{
  std::stringstream ss;
  ss << *self;
  return ss.str();
}

// For Python standard library 'random' interface.
std::string getState()
{
  std::stringstream ss;
  ss << *self;
  return ss.str();
}

// For Python standard library 'random' interface.
void setState(const std::string &s)
{
  std::stringstream ss(s);
  ss >> *self;
}

void setSeed(PyObject *x)
{
  long seed_ = PyObject_Hash(x);
  *self = nta::Random(seed_);
}

void jumpAhead(unsigned int n)
{ // WARNING: Slow!
  while(n) { self->getUInt32(nta::Random::MAX32); --n; }
}

inline void initializeUInt32Array(PyObject* py_array, nta::UInt32 max_value)
{
  PyArrayObject* array = (PyArrayObject*) py_array;
  nta::UInt32* array_data = (nta::UInt32*) array->data;
  nta::UInt32 size = array->dimensions[0];
  for (nta::UInt32 i = 0; i != size; ++i)
    array_data[i] = self->getUInt32() % max_value;
}

inline void initializeReal32Array(PyObject* py_array)
{
  PyArrayObject* array = (PyArrayObject*) py_array;
  nta::Real32* array_data = (nta::Real32*) array->data;
  nta::UInt32 size = array->dimensions[0];
  for (nta::UInt32 i = 0; i != size; ++i)
    array_data[i] = (nta::Real32) self->getReal64();
}

inline void initializeReal32Array_01(PyObject* py_array, nta::Real32 proba)
{
  PyArrayObject* array = (PyArrayObject*) py_array;
  nta::Real32* array_data = (nta::Real32*) array->data;
  nta::Real32 size = array->dimensions[0];
  for (nta::UInt32 i = 0; i != size; ++i)
    array_data[i] = (nta::Real32)(self->getReal64() <= proba ? 1.0 : 0.0);
}

inline PyObject* sample(PyObject* population, PyObject* choices)
{
  if (PyArray_Check(population) && PyArray_Check(choices))
  {
    PyArrayObject* values = (PyArrayObject*) population;
    PyArrayObject* result = (PyArrayObject*) choices;

    if (values->nd != 1 || result->nd != 1)
    {
      PyErr_SetString(PyExc_ValueError,
                     "Only one dimensional arrays are supported.");
      return NULL;
    }

    if (PyArray_DESCR(values)->type_num != PyArray_DESCR(result)->type_num)
    {
      PyErr_SetString(
          PyExc_ValueError,
          "Type of value in polation and choices arrays must match.");
      return NULL;
    }

    try
    {
      if (PyArray_DESCR(values)->type_num == NPY_UINT32)
      {
        nta::UInt32* valuesStart = (nta::UInt32*) values->data;
        nta::UInt32 valuesSize = values->dimensions[0];

        nta::UInt32* resultStart = (nta::UInt32*) result->data;
        nta::UInt32 resultSize = result->dimensions[0];

        self->sample(valuesStart, valuesSize, resultStart, resultSize);
      } else if (PyArray_DESCR(values)->type_num == NPY_UINT64) {
        nta::UInt64* valuesStart = (nta::UInt64*) values->data;
        nta::UInt64 valuesSize = values->dimensions[0];

        nta::UInt64* resultStart = (nta::UInt64*) result->data;
        nta::UInt64 resultSize = result->dimensions[0];

        self->sample(valuesStart, valuesSize, resultStart, resultSize);
      } else {
        PyErr_SetString(PyExc_TypeError,
                       "Unexpected array dtype. Expected 'uint32' or 'uint64'.");
        return NULL;
      }
    }
    catch (nta::LoggingException& exception)
    {
      PyErr_SetString(PyExc_ValueError, exception.getMessage());
      return NULL;
    }
  } else {
    PyErr_SetString(PyExc_TypeError,
                   "Unsupported type. Expected Numpy array.");
    return NULL;
  }

  Py_INCREF(choices);
  return choices;
}

inline PyObject* shuffle(PyObject* obj)
{
  if (PyArray_Check(obj))
  {
    PyArrayObject* arr = (PyArrayObject*) obj;

    if (arr->nd != 1)
    {
      PyErr_SetString(PyExc_ValueError,
                     "Only one dimensional arrays are supported.");
      return NULL;
    }

    if (PyArray_DESCR(arr)->type_num == NPY_UINT32)
    {
      nta::UInt32* arrStart = (nta::UInt32*) arr->data;
      nta::UInt32* arrEnd = arrStart + arr->dimensions[0];

      self->shuffle(arrStart, arrEnd);
    } else if (PyArray_DESCR(arr)->type_num == NPY_UINT64) {
      nta::UInt64* arrStart = (nta::UInt64*) arr->data;
      nta::UInt64* arrEnd = arrStart + arr->dimensions[0];

      self->shuffle(arrStart, arrEnd);
    } else {
      PyErr_SetString(PyExc_ValueError,
                     "Unexpected array dtype. Expected 'uint32' or 'uint64'.");
      return NULL;
    }
  } else {
    PyErr_SetString(PyExc_TypeError,
                   "Unsupported type. Expected Numpy array.");
    return NULL;
  }

  Py_INCREF(obj);
  return obj;
}

} // End extend nta::Random.

%pythoncode %{
import random
class StdRandom(random.Random):
  """An adapter for nta::Random that allows use of inherited samplers 
  from the Python standard library 'random' module."""
  def __init__(self, *args, **keywords):
    self.rgen = Random(*args, **keywords)
  def random(self): return self.rgen.getReal64()
  def setstate(self, state): self.rgen.setState(state)
  def getstate(self): return self.rgen.getState()
  def jumpahead(self, n): self.rgen.jumpAhead(n)
  def seed(self, seed=None):
    if seed is None: self.rgen.setSeed(0)
    else: self.rgen.setSeed(seed)
%}
